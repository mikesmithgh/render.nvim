local render_constants = require('render.constants')
local render_fn = require('render.fn')
local render_windowinfo = require('render.windowinfo')
local render_screencapture = require('render.screencapture')
local render_keymaps = require('render.keymaps')
local render_msg = require('render.msg')

local M = {}

---Configuration options to modify behavior of render.nvim
---@class RenderOptions
---@field features Features Feature flags to toggle behavior
---@field notify Notify Notification configuration
local standard_opts = {
  ---@class Features
  ---@field notify boolean If true, send notify messages
  ---@field keymaps boolean If true, setup default keymappings
  ---@field flash boolean If true, flash effect by changing background and foreground color before a screencapture
  ---@field auto_open boolean If true, open the file after the screencapture
  ---@field auto_preview boolean If true, preview the file after the screencapture
  ---@field sound_effect boolean If true, play a sound effect during screencapture
  features = {
    notify = true,
    keymaps = true,
    flash = true,
    auto_open = false,
    auto_preview = true,
    sound_effect = false,
  },
  ---@class Notify
  ---@field level number Level of notification corresponding to `vim.log.levels`
  ---@field msg function The function that will be invoked for notifications
  ---@field verbose boolean If true, enable additional information in notifications
  notify = {
    level = vim.log.levels.INFO,
    msg = render_msg.notify,
    verbose = true,
  },
  ---@class Functions
  ---@field window_info FunctionsWindowInfo
  ---@field screencapture FunctionsScreenCapture
  ---@field screencapture_location FunctionsScreenCaptureLocation
  ---@field keymap_setup function
  ---@field flash function
  ---@field open_cmd function
  fn = {
    ---@class FunctionsWindowInfo
    ---@field cmd function
    ---@field opts function
    window_info = {
      cmd = render_windowinfo.cmd,
      opts = render_windowinfo.cmd_opts,
    },
    ---@class FunctionsScreenCapture
    ---@field cmd function
    ---@field opts function
    screencapture = {
      cmd = render_screencapture.cmd,
      opts = render_screencapture.cmd_opts,
    },
    ---@class FunctionsScreenCaptureLocation
    ---@field cmd function
    ---@field opts function
    screencapture_location = {
      cmd = render_screencapture.location_cmd,
      opts = render_screencapture.location_cmd_opts,
    },
    keymap_setup = render_keymaps.setup_default_keymaps,
    flash = render_fn.flash,
    open_cmd = render_fn.open_cmd,
  },
  ---@class Directories
  ---@field data string
  ---@field state string
  ---@field run string
  ---@field output string
  dirs = {
    data = vim.fn.stdpath('data') .. '/' .. render_constants.shortname,
    state = vim.fn.stdpath('state') .. '/' .. render_constants.shortname,
    run = vim.fn.stdpath('run') .. '/' .. render_constants.shortname,
    output = vim.fn.stdpath('data') .. '/' .. render_constants.shortname .. '/output',
  },
  profiles = vim.tbl_deep_extend('force', {
    ---@class ProfileOptions
    ---@field mode 'save' | 'clipboard' | 'preview' | 'open'
    ---@field image_capture_mode 'bounds' | 'window'
    ---@field capture_window_info_mode string | 'frontmost' | 'frontmost_on_startup' | 'manual'
    ---@field filetype string | 'png' | 'jpg' | 'pdf' | 'psd' | 'tga' | 'bmp' | 'gif' | 'tiff' | 'mov'
    ---@field delay integer? Take the capture after a delay seconds
    ---@field show_clicks boolean If true, show clicks in video recording mode
    ---@field video_limit integer Limits video capture to the specific seconds
    ---@field dry_run boolean If true, do not take screencapture. This is useful for troubleshooting
    ---@field offsets ModeOptionsOffsets Offsets to rectangle in bounds image capture mode
    ---@field window_shadow boolean If true, create a shadow around the screencapture when image_capture_mode is window
    default = {
      mode = render_constants.screencapture.mode.save,
      image_capture_mode = render_constants.screencapture.capturemode.window,
      capture_window_info_mode = render_constants.screencapture.window_info_mode.frontmost_on_startup,
      filetype = render_constants.png,
      delay = nil,
      show_clicks = false,
      video_limit = 60,
      dry_run = false,
      ---Positive and negative integers are valid
      ---@class ModeOptionsOffsets
      ---@field left integer Number of units to adjust left bounds
      ---@field top integer Number of units to adjust top bounds
      ---@field right integer Number of units to adjust right bounds
      ---@field bottom integer Number of units to adjust bottom bounds
      offsets = {
        left = 0,
        top = 0, -- 27, tested with iterm,
        right = 0, -- 13,
        bottom = 0,
      },
      window_shadow = false,
    },
  }, require('render.example-profiles')),
  ---@class UserInterface
  ---Function returning a color name or "#RRGGBB" that will be
  ---displayed during screen flash
  ---@field flash_color fun(): string
  ---Function returning a table defining configuration options for
  ---delay countdown window
  ---@field countdown_window_opts fun(): table
  ---@see nvim_set_hl()
  ---@see nvim_open_win()
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
  return vim.tbl_deep_extend('force', {}, standard_opts)
end

M.opts = {}

return M
