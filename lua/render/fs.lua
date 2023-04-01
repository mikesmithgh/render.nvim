local render_msg = require('render.msg')
local uv = vim.loop
local M = {}
local opts = {}

M.setup = function(render_opts)
  opts = render_opts
end

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

M.read_cat_file = function(timer, out_files, callback)
  local screenshot
  -- wait until screenshot has succesfully written to file
  local ok, file_content = pcall(vim.fn.readfile, out_files.cat)
  if ok and file_content ~= nil and file_content ~= '' then
    screenshot = file_content
    timer:stop()
    timer:close()
    callback(screenshot)
  end
end

M.wait_for_cat_file = function(out_files, callback)
  local initial_delay_ms = 200
  local repeat_interval_delay_ms = 500
  local timeout_ms = 2000

  local timer = uv.new_timer()
  if timer == nil then
    render_msg.notify('error reading file; failed to create timer', vim.log.levels.ERROR, {
      err = {
        file = out_files.cat,
      },
    })
    return
  end

  timer:start(
    initial_delay_ms,
    repeat_interval_delay_ms,
    vim.schedule_wrap(function()
      M.read_cat_file(timer, out_files, callback)
    end)
  )
  vim.defer_fn(function()
    if timer:is_active() then
      timer:stop()
      timer:close()
      render_msg.notify('error reading file; timeout', vim.log.levels.ERROR, {
        err = {
          file = out_files.cat,
        },
      })
    end
  end, timeout_ms)
end


M.setup_files_and_dirs = function()
  M.create_dirs(opts.dirs)

  local ok, err = pcall(M.generateCSSFile, opts.font, opts.files.render_css)
  if not ok then
    -- TODO: move to notify module to avoid loop
    render_msg.notify(err, vim.log.levels.ERROR, {
      font = opts.font,
      render_style = opts.files.render_css,
    })
  end

  local init_files = {}
  init_files[opts.files.runtime_fonts] = opts.dirs.font
  init_files[opts.files.runtime_scripts] = opts.dirs.scripts
  ok, err = pcall(M.createInitFiles, init_files)
  if not ok then
    render_msg.notify(err, vim.log.levels.ERROR, {
      font = opts.font,
      render_style = opts.files.render_css,
    })
  end
end


return M
