local M = {}
local render_msg = require('render.msg')
local render_fs = require('render.fs')
local render_fn = require('render.fn')

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
end

M.render = function()
  local out_files = render_fn.new_output_files()

  vim.fn.jobstart(
    opts.fn.window_info.cmd(),
    opts.fn.window_info.opts(out_files)
  )
end

return M
