local render_msg = require('render.msg')
local uv = vim.loop
local M = {}
local opts = {}

---@param render_opts RenderOptions
M.setup = function(render_opts)
  opts = render_opts
  M.setup_files_and_dirs()
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

M.createInitFiles = function(init_files)
  for sources, destination_dir in pairs(init_files) do
    for _, source in pairs(sources) do
      local dest = destination_dir .. '/' .. vim.fn.fnamemodify(source, ':t')
      uv.fs_copyfile(source, dest, { excl = true }, function(err, success) end)
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
    opts.notify.msg('error reading file; failed to create timer', vim.log.levels.ERROR, {
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
      opts.notify.msg('error reading file; timeout', vim.log.levels.ERROR, {
        err = {
          file = out_files.cat,
        },
      })
    end
  end, timeout_ms)
end

M.setup_files_and_dirs = function()
  M.create_dirs(opts.dirs)
end

return M
