local uv = vim.loop
local M = {}

local function error_ignore(err, ignore_errnos)
  if err ~= nil then
    local err_name = err:gmatch('([^:]+)')() -- split on :

    for _, ignore_errno in pairs(ignore_errnos) do
      local errno = uv.errno[err_name]
      if errno == ignore_errno then
        return true, nil
      end
    end
    return false, error(err)
  end
end

M.generateCSSFile = function(font, destination)
  uv.fs_open(destination, 'ax', tonumber('644', 8), function(err, fd)
    local ignore, fs_err = error_ignore(err, { uv.errno.EEXIST })
    if ignore then
      return
    end
    if fs_err ~= nil then
      error(fs_err)
    end

    local font_family = {}

    for _, face in pairs(font.faces) do
      uv.fs_write(fd, '@font-face {\n')
      uv.fs_write(fd, '    font-family: "' .. face.name .. '";\n')
      uv.fs_write(fd, '    src: ' .. face.src .. ';\n')
      uv.fs_write(fd, '}\n\n')

      table.insert(font_family, '"' .. face.name .. '"')
    end

    uv.fs_write(fd, '* {\n')
    uv.fs_write(fd, '    font-family: ' .. table.concat(font_family, ', ') .. ';\n')
    uv.fs_write(fd, '    font-size: ' .. font.size .. 'px;\n')
    uv.fs_write(fd, '}\n\n\n')
    uv.fs_write(fd, 'pre {\n')
    uv.fs_write(fd, '    position: absolute;\n')
    uv.fs_write(fd, '    /* avoid pre first line spacing */\n')
    uv.fs_write(fd, '    top: -1em;\n')
    uv.fs_write(fd, '    left: 0em;\n')
    uv.fs_write(fd, '}\n\n')

    uv.fs_close(fd)
  end)
end

M.createInitFiles = function(init_files)
  for sources, destination_dir in pairs(init_files) do
    for _, source in pairs(sources) do
      local dest = destination_dir .. '/' .. vim.fn.fnamemodify(source, ':t')
      uv.fs_copyfile(source, dest, { excl = true }, function(err, success)
        if success == nil then
          local ignore, fs_err = error_ignore(err, { uv.errno.EEXIST })
          if ignore then
            return
          end
          if fs_err ~= nil then
            error(fs_err)
          end
        end
      end)
    end
  end
end

M.remove_dirs = function(dirs)
  for _, dir in pairs(dirs) do
    vim.fn.delete(dir, 'rf')
  end
end

M.create_dirs = function(dirs)
  for _, dir in pairs(dirs) do
    vim.fn.mkdir(dir, 'p')
  end
end

return M
