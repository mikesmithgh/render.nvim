---@mod render.api Render API

local luv = vim.loop
local M = {}
local render_fs = require('render.fs')
local render_fn = require('render.fn')
local render_windowinfo = require('render.windowinfo')
local render_cache = require('render.cache')

---@type RenderOptions
local opts = {}
---@tag render.api.setup
---@param render_opts RenderOptions|nil
M.setup = function(render_opts)
  opts = render_opts
end

---@tag render.api.render
---Take a screencapture with the given profile. The profile may
---be |ProfileOptions| or the name of a profile that exists in
---|RenderOptions|. If no profile is given, then the `default`
---profile will be used.
---@param profile ProfileOptions|string|nil
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

---@tag render.api.dryrun
---Perform a dryrun with the given profile. All operations will
---be performed excluding the actual screencapture. This is useful
---for troublehsooting and debugging.
---@param profile ProfileOptions|string|nil
---@see render.api.render
M.dryrun = function(profile)
  if type(profile) == 'string' then
    local profile_name = profile
    profile = opts.profiles[profile_name]
  end
  M.render(vim.tbl_extend('force', profile, { dry_run = true }))
end

---@class RenderCleanOptions
---@field force boolean If true, do not prompt for confirmation

---@tag render.api.clean
---Clean output directory and reinstall dependencies
---@param clean_opts RenderCleanOptions|nil
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

---@tag render.api.explore
---Open the output directory in Neovim
M.explore = function()
  vim.cmd.edit(opts.dirs.output)
end

---@tag render.api.interrupt
---Send an interrupt signal to stop all video recordings.
---If no video is found, this is a noop.
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

---@class RenderQuickfixOptions
---@field toggle boolean If true, toggle the |quickfix| window open or closed

---@tag render.api.quickfix
---Open the output directory in the |quickfix| window
---@param qf_opts RenderQuickfixOptions|nil
M.quickfix = function(qf_opts)
  if qf_opts == nil then
    qf_opts = {
      toggle = true,
    }
  end
  render_fn.render_quickfix(vim.tbl_extend('keep', { cb = vim.cmd.copen }, qf_opts))
end

---@tag render.api.quicklook
---Open all output files in quick look
---The command `qlmanage` is used to open the quick look preview.
---See https://ss64.com/osx/qlmanage.html for additional information on the
---`qlmanage` command.
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

---@tag render.api.set_window_info
---Set the window information used by render.nvim to perform screencaptures.
---If `pid` is `nil` then the `pid` of the neovim session will be used.
---This allows you to manually determine window information after neovim has started.
---
---Example usecases: ~
---  • If the neovim instance starts behind other neovim instances, then the
---    wrong window may be selected. Once the neovim instance is focused, you can
---    use `set_window_info()` to point to the correct neovim instance.
---  • You may wish to take screencaptures of other applications. This can be done
---    by determining the pid (.e.g, `ps -ef`) and running `set_window_info({pid})`.
---    Now, screencaptures perform by neovim will capture the window owning pid rather
---    than the current neovim session.
---  • If you moved the window for a profile with `image_capture_mode` set to `bounds`,
---    then screencaptures may no longer have the desired bounds. Running `set_window_info()`
---    will recalculate the bounds of the new window position.
---@param pid integer|nil The process ID of the desired application to screencapture
M.set_window_info = function(pid)
  render_windowinfo.set_window_info(pid)
end

return M
