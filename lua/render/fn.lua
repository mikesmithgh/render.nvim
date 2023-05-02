local render_constants = require('render.constants')
local M = {}

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
end

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
    windows = { cmd = 'cmd', args = { '/c', 'start', '""' } },
  }
  return cmd[M.os()]
end

M.new_output_files = function()
  local cur_name = vim.fn.expand('%:t')
  if cur_name == nil or cur_name == '' then
    cur_name = 'noname'
  end
  local normalized_name = vim.fn.substitute(cur_name, '\\W', '', 'g')
  local temp = vim.fn.tempname()
  local temp_prefix = vim.fn.fnamemodify(temp, ':h:t')
  local temp_name = vim.fn.fnamemodify(temp, ':t')
  local out_file = string.lower(
    opts.dirs.output .. '/' .. normalized_name .. '-' .. temp_prefix .. '-' .. temp_name
  )
  return {
    file = out_file,
    cat = out_file .. '.' .. render_constants.cat,
    html = out_file .. '.' .. render_constants.html,
    png = out_file .. '.' .. render_constants.png,
    jpg = out_file .. '.' .. render_constants.jpg,
    gif = out_file .. '.' .. render_constants.gif,
    pdf = out_file .. '.' .. render_constants.pdf,
    tiff = out_file .. '.' .. render_constants.tiff,
    mov = out_file .. '.' .. render_constants.mov,
  }
end

M.sanitize_ansi_screenshot = function(screenshot)
  -- parse and remove dimensions of the screenshot
  local first_line = screenshot[1]
  local dimensions = vim.fn.split(first_line, ',')
  local height = dimensions[1]
  local width = dimensions[2]
  if height ~= nil and height ~= '' and width ~= nil and width ~= '' then
    table.remove(screenshot, 1)
  end
  for i, line in pairs(screenshot) do
    -- lua's pattern matching facilities work byte by byte. in general, this will not work for unicode pattern matching, although some things will work as you want.
    -- see http://lua-users.org/wiki/LuaUnicode

    -- tmux and screen print hex 15 shift out character
    -- see https://en.wikipedia.org/wiki/shift_out_and_shift_in_characters
    line = vim.fn.substitute(line, '\\v%u0f', '', 'g')

    -- fzf-lua prints en space which is half the width of regular font
    -- see https://en.wikipedia.org/wiki/En_(typography)
    -- see https://github.com/ibhagwan/fzf-lua/blob/b454e05d44530e50c0d049b87ca6eeece958ff6a/doc/fzf-lua.txt#L1199
    screenshot[i] = vim.fn.substitute(line, '\\v%u2002', ' ', 'g')
  end
  return height, width
end

return M
