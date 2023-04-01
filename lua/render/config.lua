local render_constants = require('render.constants')
local render_fn = require('render.fn')
local render_aha = require('render.aha')
local render_playwright = require('render.playwright')
local M = {}

local standard_opts = {
  features = {
    notify = true,
    keymaps = true,
    flash = true,
    auto_open = true,
  },
  fn = {
    aha = {
      cmd = render_aha.cmd,
      opts = render_aha.cmd_opts,
    },
    playwright = {
      cmd = render_playwright.cmd,
      opts = render_playwright.cmd_opts,
    },
    keymap_setup = function()
      -- <f13> == <shift-f1> == print screen
      vim.keymap.set(
        { 'n', 'i', 'c', 'v', 'x', 's', 'o', 't', 'l' },
        '<f13>',
        '<cmd>Render<cr>',
        { silent = true, remap = true }
      )
    end,
    flash = function()
      local render_ns = vim.api.nvim_create_namespace('render')
      local normal_hl = vim.api.nvim_get_hl(0, { name = 'CursorLine' })
      local flash_color = normal_hl.bg
      if flash_color == nil or flash_color == '' then
        flash_color = '#000000'
        if vim.opt.bg:get() == 'dark' then
          flash_color = '#ffffff'
        end
      end
      vim.api.nvim_set_hl(render_ns, 'Normal', { fg = flash_color, bg = flash_color })
      vim.api.nvim_set_hl_ns(render_ns)
      vim.cmd.mode()
      vim.defer_fn(function()
        vim.api.nvim_set_hl_ns(0)
        vim.cmd.mode()
      end, 100)
    end,
    open_cmd = function()
      local cmd = {
        unix = { 'xdg-open' },
        mac = { 'open' },
        windows = { cmd = 'cmd', args = { '/c', 'start', '""' }, },
      }
      return cmd[render_fn.os()]
    end,
  },
  dirs = {
    data = vim.fn.stdpath('data') .. '/' .. render_constants.shortname,
    state = vim.fn.stdpath('state') .. '/' .. render_constants.shortname,
    run = vim.fn.stdpath('run') .. '/' .. render_constants.shortname,
    output = vim.fn.stdpath('data') .. '/' .. render_constants.shortname .. '/output',
    css = vim.fn.stdpath('data') .. '/' .. render_constants.shortname .. '/css',
    font = vim.fn.stdpath('data') .. '/' .. render_constants.shortname .. '/font',
    scripts = vim.fn.stdpath('data') .. '/' .. render_constants.shortname .. '/scripts',
  },
  files = {
    runtime_scripts = vim.api.nvim_get_runtime_file('scripts/*', true),
    runtime_fonts = vim.api.nvim_get_runtime_file('font/*', true),
  },
}
standard_opts.font = {
  faces = {
    {
      name = 'MonoLisa Trial Regular Nerd Font Complete Windows Compatible',
      src = [[url(']]
        .. standard_opts.dirs.font
        .. [[/MonoLisa Trial Regular Nerd Font Complete Windows Compatible.ttf') format("truetype")]],
    },
    {
      name = 'MonoLisa Trial Regular Italic Nerd Font Complete Windows Compatible',
      src = [[url(']]
        .. standard_opts.dirs.font
        .. [[/MonoLisa Trial Regular Italic Nerd Font Complete Windows Compatible.ttf') format("truetype")]],
    },
  },
  size = 11,
}
standard_opts.files.render_script = standard_opts.dirs.scripts .. '/' .. render_constants.shortname .. '.spec.ts'
standard_opts.files.render_css = standard_opts.dirs.css .. '/' .. render_constants.shortname .. '.css'

M.default_opts = standard_opts
M.opts = {}

return M
