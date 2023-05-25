local M = {}

M.shortname = 'render'
M.longname = 'render.nvim'

M.png = 'png'
M.jpg = 'jpg'
M.pdf = 'pdf'
M.psd = 'psd'
M.tga = 'tga'
M.bmp = 'bmp'
M.gif = 'gif'
M.tiff = 'tiff'

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

M.mov = 'mov'
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

M.screencapture = {
  type = {
    video = 'video',
    image = 'image',
  },
  mode = {
    save = 'save',
    clipboard = 'clipboard',
    preview = 'preview',
    open = 'open',
  },
  default_location = '~/Desktop',
  capturemode = {
    window = 'window',
    bounds = 'bounds',
  },
  window_info_mode = {
    frontmost = 'frontmost',
    frontmost_on_startup = 'frontmost_on_startup',
    manual = 'manual',
  },
}

return M
