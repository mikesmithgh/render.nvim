local render_constants = require('render.constants')
local render_fn = require('render.fn')
local M = {}

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
end

M.notify = function(msg, level, extra, hi)
  if opts.notify_enabled then
    vim.schedule(
      render_fn.partial(
        vim.notify,
        vim.inspect(
          vim.tbl_extend(
            'keep',
            { msg = string.format('%s: %s', render_constants.longname, msg) },
            extra
          )
        ),
        level,
        {}
      )
    )
  end
end

return M
