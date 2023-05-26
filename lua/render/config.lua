local render_constants = require('render.constants')
local render_fn = require('render.fn')
local render_windowinfo = require('render.windowinfo')
local render_screencapture = require('render.screencapture')
local render_keymaps = require('render.keymaps')
local render_msg = require('render.msg')

local M = {}

---Configuration options to modify behavior of render.nvim
---@class RenderOptions
---@field features RenderOptionsFeatures Feature flags to toggle behavior
---@field notify RenderOptionsNotify Notification configuration
local standard_opts = {
  ---@class RenderOptionsFeatures
  ---@field notify boolean If true, send notify messages
  ---@field keymaps boolean If true, setup default keymappings
  ---@field flash boolean If true, flash effect by changing background and foreground color before a screencapture
  ---@field auto_open boolean If true, open the file after the screencapture
  ---@field auto_preview boolean If true, preview the file after the screencapture
  ---@field sound_effect boolean If true, play a sound effect during screencapture
  ---@field window_shadow boolean If true, create a shadow around the screencapture when image_capture_mode is window
  features = {
    notify = true,
    keymaps = true,
    flash = true,
    auto_open = false,
    auto_preview = true,
    sound_effect = false,
    window_shadow = false,
  },
  ---@class RenderOptionsNotify
  ---@field level number Level of notification corresponding to `vim.log.levels`
  ---@field msg function The function that will be invoked for notifications
  ---@field verbose boolean If true, enable additional information in notifications
  notify = {
    level = vim.log.levels.INFO,
    msg = render_msg.notify,
    verbose = false,
  },
  ---@class RenderOptionsFunctions
  ---@field window_info RenderOptionsFunctionsWindowInfo
  ---@field screencapture RenderOptionsFunctionsScreenCapture
  ---@field screencapture_location RenderOptionsFunctionsScreenCaptureLocation
  ---@field keymap_setup function
  ---@field flash function
  ---@field open_cmd function
  fn = {
    ---@class RenderOptionsFunctionsWindowInfo
    ---@field cmd function
    ---@field opts function
    window_info = {
      cmd = render_windowinfo.cmd,
      opts = render_windowinfo.cmd_opts,
    },
    ---@class RenderOptionsFunctionsScreenCapture
    ---@field cmd function
    ---@field opts function
    screencapture = {
      cmd = render_screencapture.cmd,
      opts = render_screencapture.cmd_opts,
    },
    ---@class RenderOptionsFunctionsScreenCaptureLocation
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
  ---@class RenderOptionsDirectories
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
  ---@class RenderOptionsModeOptions
  ---@field type RenderConstantsScreenCaptureType
  ---@field mode RenderConstantsScreenCaptureMode
  ---@field image_capture_mode RenderConstantsScreenCaptureCaptureMode
  ---@field capture_window_info_mode RenderConstantsScreenCaptureWindowInfoMode
  ---@field filetype render_filetypes
  ---@field delay integer
  ---@field show_clicks boolean
  ---@field video_limit integer
  ---@field dry_run boolean
  ---@field offsets RenderOptionsModeOptionsOffsets
  mode_opts = {
    type = render_constants.screencapture.type.image,
    mode = render_constants.screencapture.mode.save,
    image_capture_mode = render_constants.screencapture.capturemode.window,
    capture_window_info_mode = render_constants.screencapture.window_info_mode.frontmost_on_startup,
    filetype = render_constants.png,
    delay = nil,
    show_clicks = false,
    video_limit = 60,
    dry_run = false,
    ---@class RenderOptionsModeOptionsOffsets
    ---@field left integer
    ---@field top integer
    ---@field right integer
    ---@field bottom integer
    offsets = {
      left = 0,
      top = 0, -- 27, tested with iterm,
      right = 0, -- 13,
      bottom = 0,
    },
  },
  ---@class RenderOptionsUserInterface
  ---@field flash_color function
  ---@field countdown_window_opts function
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
