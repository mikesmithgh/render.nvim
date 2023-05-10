local render_constants = require('render.constants')
local render_fn = require('render.fn')
local render_aha = require('render.aha')
local render_playwright = require('render.playwright')
local render_windowinfo = require('render.windowinfo')
local render_screencapture = require('render.screencapture')
local render_keymaps = require('render.keymaps')

local M = {}

local standard_opts = {
  features = {
    notify = true,
    keymaps = true,
    flash = true,
    auto_open = true,
  },
  notify = {
    level = vim.log.levels.INFO,
  },
  scale = '100%',
  fn = {
    aha = {
      cmd = render_aha.cmd,
      opts = render_aha.cmd_opts,
    },
    playwright = {
      cmd = render_playwright.cmd,
      opts = render_playwright.cmd_opts,
    },
    window_info = {
      cmd = render_windowinfo.cmd,
      opts = render_windowinfo.cmd_opts,
    },
    screencapture = {
      cmd = render_screencapture.cmd,
      opts = render_screencapture.cmd_opts,
    },
    screencapture_location = {
      cmd = render_screencapture.location_cmd,
      opts = render_screencapture.location_cmd_opts,
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
  mode_opts = {
    type = render_constants.screencapture.type.image,
    mode = render_constants.screencapture.mode.save,
    filetype = render_constants.png,
    delay = nil,
    show_clicks = false,
    video_limit = nil,
    dry_run = false,
    offsets = {
      left = 0,
      top = 0,
      right = 0,
      bottom = 0,
    },
  },
  ui = {
    flash_color = function()
      local normal_hl = vim.api.nvim_get_hl(0, { name = 'CursorLine' })
      local flash_color = normal_hl.bg
      if flash_color == nil or flash_color == '' then
        flash_color = render_constants.black_hex
        if vim.opt.bg:get() == render_constants.dark_mode then
          flash_color = render_constants.white_hex
        end
      end
      return flash_color
    end,
    countdown_window_opts = function()
      return vim.tbl_extend('force', {
        relative = 'editor',
        noautocmd = true,
        zindex = 1000,
        style = 'minimal',
        focusable = false,
      }, render_fn.center_window_options(17, 6, vim.o.columns, vim.o.lines))
    end,
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
