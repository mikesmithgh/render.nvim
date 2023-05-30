local M = {}
local render_api = require('render.api')

local opts = {}

---@param render_opts RenderOptions
M.setup = function(render_opts)
  opts = render_opts
end

M.render = render_api.render

M.render_dryrun = render_api.render_dryrun


return M
