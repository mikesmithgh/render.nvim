local render_constants = require('render.constants')
local render_fn = require('render.fn')
local M = {}

local opts = {}

---@param render_opts RenderOptions
M.setup = function(render_opts)
  opts = render_opts
end

M.notify = function(msg, level, extra)
  if
    opts.features.notify
    and opts.notify.level ~= vim.log.levels.OFF
    and level >= opts.notify.level
  then
    local message = string.format('%s: %s', render_constants.longname, msg)
    if opts.notify.verbose then
      message = vim.inspect(
        vim.tbl_extend(
          'keep',
          { msg = string.format('%s: %s', render_constants.longname, msg) },
          extra
        ),
        { newline = ' ', indent = ' ' }
      )
    end

    vim.schedule(render_fn.partial(vim.notify, message, level, {}))
  end
end

return M
