local M = {}
local render_constants = require('render.constants')
local render_fn = require('render.fn')

local opts = {}

---@param render_opts RenderOptions
M.setup = function(render_opts)
  opts = render_opts
end

---@param mode_opts RenderOptionsModeOptions
M.render = function(mode_opts)
  if mode_opts == nil then
    mode_opts = opts.mode_opts
  end

  local out_files = render_fn.new_output_files()

  vim.fn.jobstart(opts.fn.window_info.cmd(), opts.fn.window_info.opts(out_files, mode_opts))
end

M.render_dryrun = function()
  local mode_opts = vim.tbl_extend('force', opts.mode_opts, {
    dry_run = true,
  })
  M.render(mode_opts)
end

return M
