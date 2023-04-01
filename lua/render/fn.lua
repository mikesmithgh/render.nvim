local render_constants = require('render.constants')
local M = {}

M.partial = function(fn, ...)
  local n, args = select('#', ...), { ... }
  return function()
    return fn(unpack(args, 1, n))
  end
end

M.os = function()
  if vim.fn.has('mac') == 1 or vim.fn.has('macunix') == 1 then
    return 'mac'
  end
  if vim.fn.has('unix') == 1 then
    return 'unix'
  end
  if vim.fn.has('win32') == 1 or vim.fn.has('win32unix') == 1 then
    return 'windows'
  end
  return nil
end

M.flash = function()
  local render_ns = vim.api.nvim_create_namespace('render')
  local normal_hl = vim.api.nvim_get_hl(0, { name = 'CursorLine' })
  local flash_color = normal_hl.bg
  if flash_color == nil or flash_color == '' then
    flash_color = render_constants.black_hex
    if vim.opt.bg:get() == render_constants.dark_mode then
      flash_color = render_constants.white_hex
    end
  end
  vim.api.nvim_set_hl(render_ns, 'Normal', { fg = flash_color, bg = flash_color })
  vim.api.nvim_set_hl_ns(render_ns)
  vim.cmd.mode()
  vim.defer_fn(function()
    vim.api.nvim_set_hl_ns(0)
    vim.cmd.mode()
  end, 100)
end

M.open_cmd = function()
  local cmd = {
    unix = { 'xdg-open' },
    mac = { 'open' },
    windows = { cmd = 'cmd', args = { '/c', 'start', '""' }, },
  }
  return cmd[M.os()]
end

return M
