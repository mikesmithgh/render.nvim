local M = {}

M.shortname = 'render'
M.longname = 'render.nvim'
M.render_deps_dir = '.render.deps'
M.pdubs = 'pdubs'
M.pdubs_dir = M.render_deps_dir .. '/pdubs'
M.pdubs_file = M.pdubs_dir .. '/pdubs'

M.png = 'png'
M.jpg = 'jpg'
M.pdf = 'pdf'
M.psd = 'psd'
M.tga = 'tga'
M.bmp = 'bmp'
M.gif = 'gif'
M.tiff = 'tiff'
M.mov = 'mov'

---@enum image_types
M.image_types = {
  M.png,
  M.jpg,
  M.pdf,
  M.psd,
  M.tga,
  M.bmp,
  M.gif,
  M.tiff,
}

---@enum video_types
M.video_types = {
  M.mov,
}

local all_types = {}
-- create a shallow copy to avoid mutating during list extend
for k, v in pairs(M.image_types) do
  all_types[k] = v
end
vim.list_extend(all_types, M.video_types)
M.all_types = all_types

---@enum extension_description
M.extension_description = {
  bmp = 'Bitmap',
  cat = 'ANSI Escape Sequences',
  html = 'HyperText Markup Language',
  png = 'Portable Network Graphics',
  psd = 'Photoshop Document',
  jpg = 'Joint Photographic Experts Group',
  jpeg = 'Joint Photographic Experts Group',
  gif = 'Graphics Interchange Format',
  tiff = 'Tagged Image File Format',
  tga = 'Truevision Graphics Adapter',
  pdf = 'Portable Document Format ',
  mov = 'QuickTime File Format (QTFF)',
  qt = 'QuickTime File Format (QTFF)',
}

M.dark_mode = 'dark'
M.white_hex = '#000000'
M.black_hex = '#ffffff'

M.unnamed_file = 'noname'

---@class ScreenCapture
---@field type ScreenCaptureType
---@field mode ScreenCaptureMode
---@field default_location string
---@field capturemode ScreenCaptureCaptureMode
---@field window_info_mode ScreenCaptureWindowInfoMode
M.screencapture = {
  ---@class ScreenCaptureType
  ---@field image string image
  ---@field video string video
  type = {
    image = 'image',
    video = 'video',
  },
  ---@class ScreenCaptureMode
  ---@field save string save
  ---@field clipboard string clipboard
  ---@field preview string preview
  ---@field open string open
  ---@enum
  mode = {
    save = 'save',
    clipboard = 'clipboard',
    preview = 'preview',
    open = 'open',
  },
  default_location = '~/Desktop',
  ---@class ScreenCaptureCaptureMode
  ---@field window string window
  ---@field bounds string bounds
  ---@enum
  capturemode = {
    window = 'window',
    bounds = 'bounds',
  },
  ---@class ScreenCaptureWindowInfoMode
  ---@field frontmost string frontmost
  ---@field frontmost_on_startup string frontmost_on_startup
  ---@field manual string manual
  ---@enum
  window_info_mode = {
    frontmost = 'frontmost',
    frontmost_on_startup = 'frontmost_on_startup',
    manual = 'manual',
  },
}

return M
