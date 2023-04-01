local render_constants = require('render.constants')
local render_fn = require('render.fn')
local render_aha = require('render.aha')
local render_playwright = require('render.playwright')
local render_keymaps = require('render.keymaps')
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
    keymap_setup = render_keymaps.setup_default_keymaps,
    flash = render_fn.flash,
    open_cmd = render_fn.open_cmd,
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
      name = render_constants.normal_font,
      src = [[url(']]
        .. standard_opts.dirs.font
        .. '/'
        .. render_constants.normal_font
        .. '.'
        .. render_constants.ttf
        .. [[') format("truetype")]],
    },
    {
      name = render_constants.italic_font,
      src = [[url(']]
        .. standard_opts.dirs.font
        .. '/'
        .. render_constants.italic_font
        .. '.'
        .. render_constants.ttf
        .. [[') format("truetype")]],
    },
  },
  size = 11,
}
standard_opts.files.render_script = standard_opts.dirs.scripts
  .. '/'
  .. render_constants.shortname
  .. '.spec.ts'
standard_opts.files.render_css = standard_opts.dirs.css
  .. '/'
  .. render_constants.shortname
  .. '.css'

M.default_opts = standard_opts
M.opts = {}

return M
