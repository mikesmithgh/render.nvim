local render_constants = require('render.constants')
local render_fn = require('render.fn')
local render_windowinfo = require('render.windowinfo')
local render_screencapture = require('render.screencapture')
local render_keymaps = require('render.keymaps')
local render_msg = require('render.msg')

local M = {}

local standard_opts = {
  features = {
    notify = true,
    keymaps = true,
    flash = true,
    auto_open = false,
    auto_preview = true,
    sound_effect = false,
    window_shadow = false,
  },
  notify = {
    level = vim.log.levels.INFO,
    msg = render_msg.notify,
    verbose = false,
  },
  fn = {
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
  },
  files = {},
  mode_opts = {
    type = render_constants.screencapture.type.image,
    mode = render_constants.screencapture.mode.save,
    image_capture_mode = render_constants.screencapture.capturemode.window,
    capture_window_info_mode = render_constants.screencapture.window_info_mode.frontmost_on_startup,
    filetype = render_constants.png,
    delay = nil,
    show_clicks = false,
    video_limit = 5,
    dry_run = false,
    offsets = {
      left = 0,
      top = 0, -- 27, tested with iterm,
      right = 0, -- 13,
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

M.default_opts = function()
  return standard_opts
end

M.opts = {}

return M
