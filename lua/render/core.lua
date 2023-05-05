local M = {}
local render_constants = require('render.constants')
local render_fn = require('render.fn')

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
end

M.render = function(mode_opts)
  if mode_opts == nil then
    mode_opts = opts.mode_opts
  end

  local out_files = render_fn.new_output_files()

  vim.fn.jobstart(
    opts.fn.window_info.cmd(),
    opts.fn.window_info.opts(out_files, mode_opts)
  )
end

M.render_png = function()
  local mode_opts = vim.tbl_extend('force', opts.mode_opts, {
    type = render_constants.screencapture.type.image,
    filetype = render_constants.png,
  })
  M.render(mode_opts)
end

M.render_jpg = function()
  local mode_opts = vim.tbl_extend('force', opts.mode_opts, {
    type = render_constants.screencapture.type.image,
    filetype = render_constants.jpg,
  })
  M.render(mode_opts)
end

M.render_gif = function()
  local mode_opts = vim.tbl_extend('force', opts.mode_opts, {
    type = render_constants.screencapture.type.image,
    filetype = render_constants.gif,
  })
  M.render(mode_opts)
end

M.render_tiff = function()
  local mode_opts = vim.tbl_extend('force', opts.mode_opts, {
    type = render_constants.screencapture.type.image,
    filetype = render_constants.tiff,
  })
  M.render(mode_opts)
end

M.render_pdf = function()
  local mode_opts = vim.tbl_extend('force', opts.mode_opts, {
    type = render_constants.screencapture.type.image,
    filetype = render_constants.pdf,
  })
  M.render(mode_opts)
end

M.render_video = function()
  local mode_opts = vim.tbl_extend('force', opts.mode_opts, {
    type = render_constants.screencapture.type.video,
    filetype = render_constants.mov,
  })
  M.render(mode_opts)
end

M.render_dryrun = function()
  local mode_opts = vim.tbl_extend('force', opts.mode_opts, {
    dry_run = true,
  })
  M.render(mode_opts)
end

return M
