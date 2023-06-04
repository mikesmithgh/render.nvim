local uv = vim.loop
local render_fn = require('render.fn')
local render_constants = require('render.constants')
local render_cache = require('render.cache')

local M = {}

---@type RenderOptions
local opts = {}

local valid_sha256s = {
  ['pdubs.tar.gz'] = 'bb8ed34f449825fb4bbfefaa85229a7a5d7130da06aa427011555322bdb5b428',
}
local pdubs_download_url = 'https://github.com/mikesmithgh/pdubs/releases/download/v1.0.0/'

M.with_offsets = function(window_info, window_offsets)
  if window_info == nil or next(window_info) == nil then
    opts.notify.msg('error getting window info', vim.log.levels.ERROR, {})
    return nil
  end
  local info = vim.tbl_extend('force', {}, window_info)
  local offsets = vim.tbl_extend('force', {
    left = 0,
    right = 0,
    up = 0,
    down = 0,
  }, window_offsets)
  info.x = math.floor(window_info.x) + (offsets.left or 0)
  info.y = math.floor(window_info.y) + (offsets.top or 0)
  info.width = math.floor(window_info.width) - (offsets.left or 0) - (offsets.right or 0)
  info.height = math.floor(window_info.height) - (offsets.top or 0) - (offsets.bottom or 0)
  return info
end

---@class RenderWindowInfo
---@field x integer window x position
---@field y integer window y position
---@field width integer window width
---@field height integer window height
---@field id integer window number

---comment
---@param json string
---@return RenderWindowInfo
M.as_window_info = function(json)
  if json == nil or next(json) == nil or json == '' or json[1] == '' then
    opts.notify.msg('error getting window info', vim.log.levels.ERROR, {})
    return nil
  end
  local window_info = nil
  local result = vim.json.decode(table.concat(json))
  if result ~= nil and result[1] ~= nil then
    window_info = {}
    local bounds = result[1].kCGWindowBounds
    window_info.x = math.floor(bounds.X)
    window_info.y = math.floor(bounds.Y)
    window_info.width = math.floor(bounds.Width)
    window_info.height = math.floor(bounds.Height)
    window_info.id = result[1].kCGWindowNumber
  end
  return window_info
end

M.render_deps_dir = function()
  return vim.api.nvim_get_runtime_file(render_constants.render_deps_dir, false)[1]
end
M.pdubs_dir = function()
  return vim.api.nvim_get_runtime_file(render_constants.pdubs_dir, false)[1]
end
M.pdubs_fpath = function()
  return vim.api.nvim_get_runtime_file(render_constants.pdubs_file, false)[1]
end

---comment
---@param pid? integer
M.set_window_info = function(pid)
  local window_info_cmd = opts.fn.window_info.cmd()
  if pid ~= nil and pid ~= '' then
    window_info_cmd = window_info_cmd .. ' ' .. pid
  end
  profile = render_fn.profile_or_default(profile, opts.profiles)
  if profile == nil then
    return
  end
  local dir = M.pdubs_dir()
  if dir == nil then
    opts.notify.msg('error getting pdubs dir', vim.log.levels.ERROR, {})
    return
  end
  vim.fn.jobstart(window_info_cmd, {
    stdout_buffered = true,
    stderr_buffered = true,
    cwd = dir,
    on_stdout = function(_, window_info_result)
      local window_info = M.as_window_info(window_info_result)
      if window_info == nil then
        return
      end
      render_cache.window.x = window_info.x
      render_cache.window.y = window_info.y
      render_cache.window.width = window_info.width
      render_cache.window.height = window_info.height
      render_cache.window.id = window_info.id
    end,
    on_stderr = function(_, result)
      if result[1] ~= nil and result[1] ~= '' then
        opts.notify.msg('error getting window id', vim.log.levels.ERROR, result)
      end
    end,
  })
end

M.remove_pdubs = function()
  local render_deps = M.render_deps_dir()
  local pdubs_dir = M.pdubs_dir()
  local pdubs_fpath = M.pdubs_fpath()

  if render_deps == nil then
    opts.notify.msg('pdubs failed to find render deps directory', vim.log.levels.ERROR, {
      dir = render_constants.render_deps_dir,
    })
    return false
  end

  if pdubs_dir == nil or pdubs_fpath == nil then
    return true
  else
    if vim.fn.delete(pdubs_dir, 'rf') == 0 then
      opts.notify.msg('pdubs successfully deleted pdubs directory', vim.log.levels.DEBUG, {
        dir = pdubs_dir,
      })
      return true
    else
      opts.notify.msg('pdubs failed to delete pdubs directory', vim.log.levels.ERROR, {
        dir = pdubs_dir,
      })
    end
  end
  return false
end

M.install_pdubs = function()
  local render_deps = M.render_deps_dir()
  local pdubs_dir = M.pdubs_dir()
  local pdubs_fpath = M.pdubs_fpath()

  if render_deps == nil then
    opts.notify.msg('pdubs failed to find render deps directory', vim.log.levels.ERROR, {
      dir = render_constants.render_deps_dir,
    })
    return false
  end

  if pdubs_dir == nil then
    vim.fn.mkdir(render_deps .. '/pdubs')
    pdubs_dir = M.pdubs_dir()
  end

  if pdubs_dir ~= nil and pdubs_fpath == nil then
    local targz_fname = 'pdubs.tar.gz'
    local targz_fpath = pdubs_dir .. '/' .. targz_fname
    local download_url = pdubs_download_url .. targz_fname
    if render_fn.download_file(download_url, pdubs_dir, targz_fname) then
      if render_fn.check_sha256(valid_sha256s[targz_fname], targz_fpath) then
        if render_fn.extract_targz(targz_fpath, pdubs_dir) then
          if uv.fs_stat(pdubs_dir .. '/pdubs') then
            opts.notify.msg('pdubs successfully downloaded and verified', vim.log.levels.DEBUG, {})
          else
            opts.notify.msg('pdubs not found after extracting file', vim.log.levels.ERROR, {
              file = targz_fpath,
            })
          end
        else
          opts.notify.msg('pdubs failed to extracting file', vim.log.levels.ERROR, {
            file = targz_fpath,
          })
        end
      else
        opts.notify.msg('pdubs sha256 mismatch, deleting unverified file', vim.log.levels.ERROR, {
          file = targz_fpath,
        })
        if vim.fn.delete(targz_fpath) == 0 then
          opts.notify.msg('pdubs successfully deleted unverified file', vim.log.levels.DEBUG, {
            file = targz_fpath,
          })
        else
          opts.notify.msg('pdubs failed to delete unverified file', vim.log.levels.ERROR, {
            file = targz_fpath,
          })
        end
      end
    else
      opts.notify.msg('pdubs failed to download file', vim.log.levels.ERROR, {
        url = download_url,
      })
    end
  end

  -- get the file again to verify it exists
  pdubs_fpath = M.pdubs_fpath()
  if pdubs_fpath == nil then
    opts.notify.msg('pdubs binary not found on runtime path', vim.log.levels.ERROR, {
      path = render_constants.pdubs_file,
    })
  else
    opts.notify.msg('pdubs binary found on runtime path', vim.log.levels.DEBUG, {
      path = render_constants.pdubs_file,
    })
    return true
  end
  return false
end

---comment
---@param render_opts RenderOptions
---@param profile? ProfileOptions
M.setup = function(render_opts, profile)
  opts = render_opts

  profile = render_fn.profile_or_default(profile, opts.profiles)
  if profile == nil then
    return
  end
  local window_info_mode = render_constants.screencapture.window_info_mode
  if
    M.install_pdubs()
    and profile.capture_window_info_mode == window_info_mode.frontmost_on_startup
  then
    M.set_window_info()
  end
end

M.cmd = function()
  return render_constants.pdubs
end

---comment
---@param out_files table
---@param profile ProfileOptions
---@return table
M.cmd_opts = function(out_files, profile)
  local screencapture = render_constants.screencapture
  local filetype = profile.filetype
  local is_video = vim.tbl_contains(render_constants.video_types, filetype)
  return {
    stdout_buffered = true,
    stderr_buffered = true,
    cwd = M.pdubs_dir(),
    on_stdout = function(_, window_info_result)
      local window_info = M.as_window_info(window_info_result)
      if window_info == nil then
        return
      end
      local wid = render_cache.window.id
      local x = render_cache.window.x
      local y = render_cache.window.y
      local width = render_cache.window.width
      local height = render_cache.window.height
      if profile.capture_window_info_mode == screencapture.window_info_mode.frontmost then
        wid = window_info.id
        x = window_info.x
        y = window_info.y
        width = window_info.width
        height = window_info.height
      end
      if wid == nil or x == nil or y == nil or width == nil or height == nil then
        opts.notify.msg('error window information is nil', vim.log.levels.ERROR, window_info_result)
        return
      end
      -- TODO: clean this up
      local window_with_offsets = M.with_offsets({
        x = x,
        y = y,
        width = width,
        height = height,
      }, profile.offsets or {})
      if window_with_offsets == nil then
        return
      end
      x = window_with_offsets.x
      y = window_with_offsets.y
      width = window_with_offsets.width
      height = window_with_offsets.height

      local screencapture_cmd =
        opts.fn.screencapture.cmd(wid, x, y, width, height, out_files, profile)
      if screencapture_cmd ~= nil then
        local capture_delay = 0

        if is_video and opts.features.flash then
          opts.fn.flash()
          capture_delay = 200
        end
        vim.defer_fn(function()
          local job_id = vim.fn.jobstart(
            screencapture_cmd,
            opts.fn.screencapture.opts(out_files, profile, screencapture_cmd)
          )
          if job_id > 0 then
            local video_timer = nil
            if is_video and profile.video_limit ~= nil then
              -- limits video capture to specified seconds
              local video_timeout = profile.video_limit * 1000
              local delay = profile.delay
              if delay ~= nil then
                video_timeout = video_timeout + (delay * 1000)
              end
              video_timer = vim.defer_fn(
                render_fn.partial(vim.fn.chansend, job_id, {
                  'type any character (or ctrl-c) to stop screen recording',
                }),
                video_timeout
              )
            end
            render_cache.job_ids[job_id] = {
              window_info = window_info,
              out_files = out_files,
              timer = video_timer,
            }
          end
        end, capture_delay) -- small delay to avoid capturing flash
      end
    end,
    on_stderr = function(_, result)
      if result[1] ~= nil and result[1] ~= '' then
        opts.notify.msg('error getting window information', vim.log.levels.ERROR, result)
      end
    end,
  }
end

return M
