local uv = vim.loop
local render_fn = require('render.fn')
local render_constants = require('render.constants')

local valid_sha256s = {
  ['pdubs.tar.gz'] = 'bb8ed34f449825fb4bbfefaa85229a7a5d7130da06aa427011555322bdb5b428',
}
local pdubs_download_url = 'https://github.com/mikesmithgh/pdubs/releases/download/v1.0.0/'

local M = {}
local render_screencapture = require('render.screencapture')

local opts = {}


M.setup = function(render_opts)
  opts = render_opts

  -- TODO: move to a function
  -- TODO: add to render clean logic
  local render_deps = vim.api.nvim_get_runtime_file('.render.deps', false)[1]
  local pdubs_dir = vim.api.nvim_get_runtime_file('.render.deps/pdubs', false)[1]
  local pdubs_fpath = vim.api.nvim_get_runtime_file('.render.deps/pdubs/pdubs', false)[1]

  if render_deps == nil then
    opts.notify.msg('pdubs failed to find render deps directory', vim.log.levels.ERROR, {
      dir = '.render.deps',
    })
    return
  end

  if pdubs_dir == nil then
    vim.fn.mkdir(render_deps .. '/pdubs')
    pdubs_dir = vim.api.nvim_get_runtime_file('.render.deps/pdubs', false)[1]
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
  pdubs_fpath = vim.api.nvim_get_runtime_file('.render.deps/pdubs/pdubs', false)[1]
  if pdubs_fpath == nil then
    opts.notify.msg('pdubs binary not found on runtime path', vim.log.levels.ERROR, {
      path = '.render.deps/pdubs/pdubs',
    })
  else
    opts.notify.msg('pdubs binary found on runtime path', vim.log.levels.DEBUG, {
      path = '.render.deps/pdubs/pdubs',
    })
  end
end

M.cmd = function()
  return 'pdubs'
end

M.cmd_opts = function(out_files, mode_opts)
  local offsets = mode_opts.offsets or {}
  return {
    stdout_buffered = true,
    stderr_buffered = true,
    cwd = vim.api.nvim_get_runtime_file('.render.deps/pdubs', false)[1], -- TODO: stuff this is a var and nil check
    on_stdout = function(_, window_info_result)
      local result = vim.json.decode(table.concat(window_info_result))
      if result ~= nil and result[1] ~= nil then
        local bounds = result[1].kCGWindowBounds
        local x = math.floor(bounds.X) + (offsets.left or 0)
        local y = math.floor(bounds.Y) + (offsets.top or 0)
        local width = math.floor(bounds.Width) - (offsets.left or 0) - (offsets.right or 0)
        local height = math.floor(bounds.Height) - (offsets.top or 0) - (offsets.bottom or 0)
        if x == nil or y == nil or width == nil or height == nil then
          opts.notify.msg('error window bounds information is nil', vim.log.levels.ERROR, window_info_result)
          return
        end
        local wid = result[1].kCGWindowNumber
        if wid == nil then
          opts.notify.msg('error window ID number is nil', vim.log.levels.ERROR, window_info_result)
          return
        end
        local screencapture_cmd = opts.fn.screencapture.cmd(wid, x, y, width, height, out_files, mode_opts)
        if screencapture_cmd ~= nil then
          local capture_delay = 0

          if mode_opts.type == render_constants.screencapture.type.video and opts.features.flash then
            opts.fn.flash()
            capture_delay = 200
          end
          vim.defer_fn(
            function()
              local job_id = vim.fn.jobstart(
                screencapture_cmd,
                opts.fn.screencapture.opts(out_files, mode_opts, screencapture_cmd)
              )
              if job_id > 0 then
                render_screencapture.job_ids[job_id] = {
                  window_info = window_info_result,
                  out_files = out_files,
                }
              end
            end
            , capture_delay) -- small delay to avoid capturing flash
        end
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
