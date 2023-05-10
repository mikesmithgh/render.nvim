local M = {}
local render_msg = require('render.msg')
local render_screencapture = require('render.screencapture')

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
end

M.cmd = function()
  local window_info_script = vim.api.nvim_get_runtime_file('scripts/window_info.scpt', false)[1]
  if window_info_script == nil then
    render_msg.notify(
      'error getting window information script from runtime path',
      vim.log.levels.ERROR,
      {}
    )
    return
  end
  return {
    'osascript',
    window_info_script,
  }
end

M.cmd_opts = function(out_files, mode_opts)
  local offsets = mode_opts.offsets or {}
  return {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, window_info_result)
      local x = math.floor(window_info_result[1]) + (offsets.left or 0)
      local y = math.floor(window_info_result[2]) + (offsets.top or 0)
      local width = math.floor(window_info_result[3]) - (offsets.left or 0) - (offsets.right or 0)
      local height = math.floor(window_info_result[4]) - (offsets.top or 0) - (offsets.bottom or 0)
      if x == nil or y == nil or width == nil or height == nil then
        render_msg.notify(
          'error window information is nil',
          vim.log.levels.ERROR,
          window_info_result
        )
        return
      end

      local screencapture_cmd = opts.fn.screencapture.cmd(x, y, width, height, out_files, mode_opts)
      if screencapture_cmd ~= nil then
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
    end,
    on_stderr = function(_, result)
      if result[1] ~= nil and result[1] ~= '' then
        local msg = 'error getting window information'
        local accessibility_errors = vim.tbl_filter(function(r)
          return string.match(r, '.*assistive.*') ~= nil
        end, result)
        if next(accessibility_errors) ~= nil then
          msg = msg
            ..
            '; accessibility is disabled. Visit https://support.apple.com/guide/mac-help/allow-accessibility-apps-to-access-your-mac-mh43185/13.0/mac/13.0 to see instructions to enabled accessibility. render.nvim uses accessbility features to determine the window position and dimensions of your nvim instance.'
        end
        render_msg.notify(msg, vim.log.levels.ERROR, result)
      end
    end,
  }
end

return M
