local M = {}
local render_fs = require('render.fs')
local render_fn = require('render.fn')
local render_windowinfo = require('render.windowinfo')

---@type RenderOptions
local opts = {}

---@param render_opts RenderOptions
M.setup = function(render_opts)
  opts = render_opts
end

---@param profile ProfileOptions|string
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

  vim.fn.jobstart(
    opts.fn.window_info.cmd(),
    opts.fn.window_info.opts(out_files, profile)
  )
end

---@param profile ProfileOptions
M.render_dryrun = function(profile)
  M.render(
    vim.tbl_extend('force', profile, { dry_run = true, })
  )
end

---@class CleanOptions
---@field force boolean If true, do not prompt for confirmation

---Clean output directory and reinstall dependencies
---@param clean_opts CleanOptions
M.render_clean = function(clean_opts)
  if clean_opts == nil then
    clean_opts = {}
  end
  local choice = 1
  if not clean_opts.force then
    choice = vim.fn.confirm('Remove all files in ' .. opts.dirs.output .. '? (This cannot be undone)', '&Remove\n&Cancel', 0)
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

return M
