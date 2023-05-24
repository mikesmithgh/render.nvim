local render_constants = require('render.constants')
local M = {}
M.cache = {}

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

M.render_quickfix = function(qfopts)
  local qftitle = vim.fn.getqflist({ title = true }).title
  local populateqf = false
  if qfopts.toggle == true and qftitle == render_constants.longname then
    local nr = vim.fn.winnr('$')
    vim.cmd.cwindow()
    if nr == vim.fn.winnr('$') then
      vim.cmd.cclose()
    else
      populateqf = true
    end
  else
    populateqf = true
  end

  if populateqf then
    vim.fn.jobstart(
      '(printf "%s | render.nvim |\n" $(realpath .); ( [ $(ls -A | wc -l) -eq 0 ] || stat -f "%m %-N | %Sm" -t "%Y-%m-%dT%H:%M:%S |" * | sort --reverse --numeric-sort | cut -d" " -f2-)) | column -t',
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
                valid = true,
              }
            end

            local fname = r:gmatch('%S+')()
            local ext = vim.fn.fnamemodify(fname, ':e'):lower()
            local ext_description = render_constants.extension_description[ext]
            if ext_description ~= nil then
              fname = nil
            end
            return {
              filename = fname,
              text = r,
              valid = true,
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
                local ext_description = render_constants.extension_description[ext]
                if next(l) == nil then
                  -- first directory is the output directory
                  table.insert(l, text .. ' ' .. 'Output directory')
                elseif ext == nil or ext == '' or ext_description == nil then
                  table.insert(l, text)
                else
                  table.insert(l, text .. ' ' .. ext_description)
                end
              end
              return l
            end,
          })
          if qfopts.cb ~= nil then
            qfopts.cb()
          end
        end,
        on_stderr = function(_, result)
          if result[1] ~= nil and result[1] ~= '' then
            opts.notify.msg('error listing screencaptures', vim.log.levels.ERROR, result)
          end
        end,
      }
    )
  end
end

M.open_qfitem = function(keymap)
  local line_index = vim.fn.line('.')
  if
    vim.o.buftype == 'quickfix'
    and vim.fn.getqflist({ title = true }).title == render_constants.longname
    and line_index > 1
  then
    local items = vim.fn.getqflist({ items = true }).items
    local text = items[line_index].text
    local fname = text:gmatch('%S+')()
    local ext = vim.fn.fnamemodify(fname, ':e'):lower()
    local ext_description = render_constants.extension_description[ext]
    if ext_description == nil then
      return keymap
    end
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
  if
    vim.o.buftype == 'quickfix'
    and vim.fn.getqflist({ title = true }).title == render_constants.longname
  then
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


M.arch = function()
  local cached_arch = M.cache['arch']
  if cached_arch ~= nil and cached_arch ~= '' then
    return cached_arch
  end

  local jid = vim.fn.jobstart(
    'arch',
    {
      stdout_buffered = true,
      stderr_buffered = true,
      on_stdout = function(_, result)
        -- vim.print(result)
        M.cache['arch'] = result[1]
      end,
      -- on_stderr = function(_, result)
      --   vim.print(result)
      -- end,
    }
  )

  local exitcode = vim.fn.jobwait({ jid }, 5000)[1]
  -- TODO add logic here

  -- -1 if the timeout was exceeded
  -- -2 if the job was interrupted (by |CTRL-C|)
  -- -3 if the job-id is invalid
  return M.cache['arch']
end

M.check_sha256 = function(sha256, fpath)
  local input = "'" .. sha256 .. ' *' .. fpath .. "'"
  local cmd = 'echo ' .. input .. ' | shasum -c'
  -- vim.print(cmd)
  local jid = vim.fn.jobstart(
    cmd
  -- { [[echo ']] .. sha256 .. [[ *]] .. fpath .. [[' | shasum -c ]] },
  )
  -- vim.print('input', input)
  -- vim.fn.chansend(jid, input)
  -- vim.fn.chanclose(jid, 'stdin')
  -- { [[echo ']] .. sha256 .. [[ *]] .. fpath .. [[' | shasum -c ]] },
  return 0 == vim.fn.jobwait({ jid }, 5000)[1]
end

M.download_file = function(url, out_dir, out_fname)
  local cmd = 'curl --silent --fail --location --output ' .. out_fname .. ' ' .. url
  local jid = vim.fn.jobstart(cmd, {
    cwd = out_dir,
  })

  return 0 == vim.fn.jobwait({ jid }, 5000)[1]
end

M.extract_targz = function(fpath, out_dir)
  local cmd = 'tar -xf ' .. fpath
  local jid = vim.fn.jobstart(cmd, {
    cwd = out_dir,
  })

  return 0 == vim.fn.jobwait({ jid }, 5000)[1]
end

return M
