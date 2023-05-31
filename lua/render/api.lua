local luv = vim.loop
local M = {}
local render_fs = require('render.fs')
local render_fn = require('render.fn')
local render_windowinfo = require('render.windowinfo')
local render_cache = require('render.cache')

---@type RenderOptions
local opts = {}

---@param render_opts RenderOptions
M.setup = function(render_opts)
  opts = render_opts
end

---@param profile? ProfileOptions|string
M.render = function(profile)
  if type(profile) == 'string' then
    local profile_name = profile
    profile = opts.profiles[profile_name]
    if profile == nil then
      opts.notify.msg('profile not found', vim.log.levels.ERROR, {
        profile_name = profile_name,
      })
      return
    end
  end

  profile = render_fn.profile_or_default(profile, opts.profiles)
  if profile == nil then
    return
  end

  local out_files = render_fn.new_output_files()

  vim.fn.jobstart(opts.fn.window_info.cmd(), opts.fn.window_info.opts(out_files, profile))
end

---@param profile? ProfileOptions|string
M.dryrun = function(profile)
  if type(profile) == 'string' then
    local profile_name = profile
    profile = opts.profiles[profile_name]
  end
  M.render(vim.tbl_extend('force', profile, { dry_run = true }))
end

---@class CleanOptions
---@field force boolean If true, do not prompt for confirmation

---Clean output directory and reinstall dependencies
---@param clean_opts? CleanOptions
M.clean = function(clean_opts)
  if clean_opts == nil then
    clean_opts = {}
  end
  local choice = 1
  if not clean_opts.force then
    choice = vim.fn.confirm(
      'Remove all files in ' .. opts.dirs.output .. '? (This cannot be undone)',
      '&Remove\n&Cancel',
      0
    )
  end
  if choice == 1 then
    render_fs.remove_dirs(opts.dirs)
    render_fs.setup_files_and_dirs()
    if render_windowinfo.remove_pdubs() then
      render_windowinfo.install_pdubs()
    end
    opts.notify.msg('successfully cleaned', vim.log.levels.INFO, {})
  end
end

M.explore = function()
  vim.cmd.edit(opts.dirs.output)
end

M.interrupt = function()
  for job_id, job_info in pairs(render_cache.job_ids) do
    local timer = job_info.timer
    if job_info ~= nil and timer ~= nil then
      timer:stop()
      timer:close()
    end
    local pid = vim.fn.jobpid(job_id)
    luv.kill(pid, 'sigint')
  end
  render_cache.job_ids = {}
  for buffer_id, timer in pairs(render_cache.timers) do
    vim.api.nvim_buf_delete(buffer_id, { force = true })
    vim.fn.timer_stop(timer.timer_id)
  end
  render_cache.timers = {}
end

M.quickfix = function()
  render_fn.render_quickfix({ cb = vim.cmd.copen, toggle = true })
end

M.quicklook = function()
  vim.fn.jobstart('stat -n -f "%N " * | xargs qlmanage -p', {
    cwd = opts.dirs.output,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stderr = function(_, result)
      if result[1] ~= nil and result[1] ~= '' then
        opts.notify.msg('error opening quicklook', vim.log.levels.ERROR, result)
      end
    end,
  })
end

---comment
---@param pid integer
M.set_window_info = function(pid)
  render_windowinfo.set_window_info(pid)
end

return M
