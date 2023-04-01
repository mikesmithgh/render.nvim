local render_constants = require('render.constants')
local render_fn = require('render.fn')
local M = {}

M.notify_enabled = true

M.setup = function(opts)
  if not opts.features.notify then
    M.notify_enabled = false
  end
end

M.notify = function(msg, level, extra, hi)
  if M.notify_enabled then
    vim.schedule(
      render_fn.partial(
        vim.notify,
        vim.inspect(vim.tbl_extend('keep', { msg = string.format('%s: %s', render_constants.longname, msg) }, extra)),
        level,
        {}
      ))
  end
end

return M
