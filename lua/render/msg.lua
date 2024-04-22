local render_constants = require('render.constants')
local render_fn = require('render.fn')
local M = {}

---@type RenderOptions
local opts = {}

---@param render_opts RenderOptions
M.setup = function(render_opts)
  opts = render_opts
end

---Display a notification to the user
---@param msg string Content of the notification to show to the user
---@param level integer|nil One of the values from |vim.log.levels|
---@param extra table|nil Optional parameters
---@ref vim.notify
M.notify = function(msg, level, extra)
  if
    opts.features.notify
    and opts.notify.level ~= vim.log.levels.OFF
    and level >= opts.notify.level
  then
    local message = string.format('%s: %s', render_constants.longname, msg)
    if opts.notify.verbose then
      for k, v in pairs(extra) do
        if render_fn.trim(v) == '' then
          extra[k] = nil
        end
      end
      if extra ~= nil and next(extra) ~= nil then
        message = message .. '\n' .. vim.inspect(extra)
      end
    end
    -- partial function does not work correctly in this case
    -- when using partial, newlines are separated resulting in multiple
    -- messages when log level is ERROR
    -- wrap it with a function as a workaround
    vim.schedule(function()
      vim.notify(message, level, {})
    end)
  end
end

return M
