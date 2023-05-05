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
  return {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, window_info_result)
      local screencapture_cmd = opts.fn.screencapture.cmd(
        window_info_result[1], -- x
        window_info_result[2], -- y
        window_info_result[3], -- width
        window_info_result[4], -- height
        out_files,
        mode_opts
      )
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
        render_msg.notify('error getting window information', vim.log.levels.ERROR, result)
      end
    end,
  }
end

return M
