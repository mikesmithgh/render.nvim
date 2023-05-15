local M = {}

M.shortname = 'render'
M.longname = 'render.nvim'

M.cat = 'cat'
M.html = 'html'
M.ttf = 'ttf'

M.png = 'png'
M.jpg = 'jpg'
M.pdf = 'pdf'
M.psd = 'psd'
M.tga = 'tga'
M.bmp = 'bmp'
M.gif = 'gif'
M.tiff = 'tiff'
M.mov = 'mov'

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

M.normal_font = 'MonoLisa Trial Regular Nerd Font Complete Windows Compatible'
M.italic_font = 'MonoLisa Trial Regular Italic Nerd Font Complete Windows Compatible'

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
}

return M
