local render_constants = require('render.constants')

return {
  iterm = {
    mode = render_constants.screencapture.mode.save,
    image_capture_mode = render_constants.screencapture.capturemode.bounds,
    capture_window_info_mode = render_constants.screencapture.window_info_mode.frontmost,
    filetype = render_constants.png,
    offsets = {
      left = 0,
      top = 27,
      right = 13,
      bottom = 0,
    },
  },
  ---@type ProfileOptions
  video = {
    mode = render_constants.screencapture.mode.save,
    image_capture_mode = render_constants.screencapture.capturemode.bounds,
    capture_window_info_mode = render_constants.screencapture.window_info_mode.frontmost,
    filetype = render_constants.mov,
    video_limit = 5,
  },
}
