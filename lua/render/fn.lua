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

M.trim = function(s)
  -- see http://lua-users.org/wiki/StringTrim
  return (s:gsub('^%s*(.-)%s*$', '%1'))
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
  local flash_color = opts.ui.flash_color()
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
    mac = { 'open', '--background' },
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
    psd = out_file .. '.' .. render_constants.psd,
    bmp = out_file .. '.' .. render_constants.bmp,
    tga = out_file .. '.' .. render_constants.tga,
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

-- copied from lazy.nvim
M.center_window_options = function(width, height, columns, lines)
  local function size(max, value)
    return value > 1 and math.min(value, max) or math.floor(max * value)
  end
  return {
    width = size(columns, width),
    height = size(lines, height),
    row = math.floor((lines - height) / 2),
    col = math.floor((columns - width) / 2),
  }
end

M.render_quickfix = function(cb)
  vim.fn.jobstart(
    '(printf "%s | render.nvim |\n" $(realpath .); (stat -f "%m %-N | %Sm" -t "%Y-%m-%dT%H:%M:%S |" * | sort --reverse --numeric-sort | cut -d" " -f2-)) | column -t',
    {
      cwd = opts.dirs.output,
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(_, result)
        local result_items = vim.tbl_map(function(r)
          if r == nil or r == '' then
            return nil
          end
          if r:find('^' .. opts.dirs.output) ~= nil then
            return {
              filename = opts.dirs.output .. '/', -- / is required to identify it as a directory
              text = r,
            }
          end
          return {
            text = r
          }
        end, result)
        vim.fn.setqflist({}, ' ', {
          title = render_constants.longname,
          items = result_items,
          quickfixtextfunc = function(info)
            local items = vim.fn.getqflist({ id = info.id, items = true }).items
            local l = {}
            for idx = info.start_idx, info.end_idx do
              local text = items[idx].text
              local fname = text:gmatch('%S+')()
              local ext = vim.fn.fnamemodify(fname, ':e'):lower()
              if next(l) == nil then
                -- first directory is the output directory
                table.insert(l, text .. ' ' .. 'Output directory')
              elseif ext == nil or ext == '' then
                table.insert(l, text)
              else
                table.insert(l, text .. ' ' .. render_constants.extension_description[ext])
              end
            end
            return l
          end
        })
        if cb ~= nil then
          cb()
        end
      end,
      on_stderr = function(_, result)
        if result[1] ~= nil and result[1] ~= '' then
          -- TODO use notify
          vim.print('error listing screencaptures', vim.log.levels.ERROR, result)
        end
      end,
    })
end

M.open_qfitem = function(keymap)
  local line_index = vim.fn.line('.')
  if vim.o.buftype == 'quickfix' and vim.fn.getqflist({ title = true }).title == render_constants.longname and line_index > 1 then
    local items = vim.fn.getqflist({ items = true }).items
    local text = items[line_index].text
    local fname = text:gmatch('%S+')()
    local open_cmd = opts.fn.open_cmd()
    if open_cmd ~= nil then
      table.insert(open_cmd, fname)
      vim.fn.jobstart(open_cmd, {
        cwd = opts.dirs.output,
      })
    end
    return keymap
  end
  return keymap
end

M.quicklook_qfitem = function(keymap)
  local line_index = vim.fn.line('.')
  if vim.o.buftype == 'quickfix' and vim.fn.getqflist({ title = true }).title == render_constants.longname then
    local items = vim.fn.getqflist({ items = true }).items
    local text = items[line_index].text
    local fname = text:gmatch('%S+')()
    if line_index == 1 then -- first like is the output directory
      local open_cmd = opts.fn.open_cmd()
      if open_cmd ~= nil then
        table.insert(open_cmd, fname)
        vim.fn.jobstart(open_cmd, {
          cwd = opts.dirs.output,
        })
      end
    else
      vim.fn.jobstart('qlmanage -p ' .. fname, {
        cwd = opts.dirs.output,
      })
    end
    return
  else
    return keymap
  end
end

return M
