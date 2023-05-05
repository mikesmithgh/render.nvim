local M = {}

M.shortname = 'render'
M.longname = 'render.nvim'

M.cat = 'cat'
M.html = 'html'
M.ttf = 'ttf'

M.png = 'png'
M.jpg = 'jpg'
M.gif = 'gif'
M.pdf = 'pdf'
M.tiff = 'tiff'
M.mov = 'mov'

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
  }
}

return M
