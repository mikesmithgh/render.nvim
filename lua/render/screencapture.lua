local luv = vim.loop
local M = {
  job_ids = {}
}

local render_msg = require('render.msg')
local render_constants = require('render.constants')

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
end

M.cmd = function(x, y, width, height, out_files)
  local mode_opts = opts.mode_opts
  local mode = render_constants.screencapture.mode
  local type = render_constants.screencapture.type
  local noop = { 'sh', '-c', ':' }
  local screencapture_cmd = {
    'screencapture',
    '-R' .. x .. ',' .. y .. ',' .. width .. ',' .. height,
  }

  if mode_opts.delay ~= nil then
    -- take the capture after a delay of <seconds>
    table.insert(screencapture_cmd, '-T' .. mode_opts.delay)
  end

  if mode_opts.mode == mode.noop then
    -- no operation is used for troubleshooting
    return noop
  end

  if mode_opts.mode == mode.open then
    -- screen capture output will open in Preview or QuickTime Player if video
    table.insert(screencapture_cmd, '-P')
  end

  if mode_opts.mode == mode.clipboard then
    -- force screen capture to go to the clipboard
    table.insert(screencapture_cmd, '-c')
  end


  if mode_opts.mode == mode.preview then
    -- present UI after screencapture is complete. files passed to command line will be ignored
    table.insert(screencapture_cmd, '-u')
  end

  if mode_opts.type == nil or mode_opts.type == type.image then
    if mode_opts.filetype == nil or mode_opts.filetype == render_constants.png then
      return vim.list_extend(screencapture_cmd, {
        '-tpng',
        out_files.png,
      })
    end

    if mode_opts.filetype == render_constants.jpg then
      return vim.list_extend(screencapture_cmd, {
        '-tjpg',
        out_files.jpg,
      })
    end

    if mode_opts.filetype == render_constants.gif then
      return vim.list_extend(screencapture_cmd, {
        '-tgif',
        out_files.gif,
      })
    end

    if mode_opts.filetype == render_constants.pdf then
      return vim.list_extend(screencapture_cmd, {
        '-tpdf',
        out_files.pdf,
      })
    end

    if mode_opts.filetype == render_constants.tiff then
      return vim.list_extend(screencapture_cmd, {
        '-ttiff',
        out_files.tiff,
      })
    end
  end

  if mode_opts.type == type.video then
    if mode_opts.video_limit ~= nil then
      -- limits video capture to specified seconds
      table.insert(screencapture_cmd, '-V' .. mode_opts.video_limit)
    end

    if mode_opts.show_clicks then
      -- show clicks in video recording mode
      table.insert(screencapture_cmd, '-k')
    end

    return vim.list_extend(screencapture_cmd, {
      '-v',
      out_files.mov,
    })
  end

  render_msg.notify('unrecognized mode options', vim.log.levels.INFO, mode_opts)
  return nil
end

M.cmd_opts = function(out_files)
  local mode_opts = opts.mode_opts
  local mode = render_constants.screencapture.mode
  return {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(job_id, _)
      if opts.features.flash then
        opts.fn.flash()
      end

      local msg = nil
      if mode_opts.mode == nil or mode_opts.mode == mode.save then
        msg = { location = out_files[mode_opts.filetype] }
      end
      if mode_opts.mode == mode.clipboard then
        msg = { location = mode.clipboard }
      end
      if mode_opts.mode == mode.preview or mode_opts.mode == mode.open then
        if M.location ~= nil then
          msg = { location = M.location }
        else
          vim.fn.jobstart(
            opts.fn.screencapture_location.cmd(),
            opts.fn.screencapture_location.opts()
          )
        end
      end

      if msg ~= nil then
        render_msg.notify('screencapture available', vim.log.levels.INFO, msg)
      end

      M.job_ids[job_id] = nil
    end,
    on_stderr = function(job_id, result)
      if result[1] ~= nil and result[1] ~= '' then
        render_msg.notify('error taking screencapture', vim.log.levels.ERROR, result)
      end
      M.job_ids[job_id] = nil
    end,
  }
end

M.location_cmd = function()
  return {
    'defaults',
    'read',
    'com.apple.screencapture',
    'location',
  }
end

M.location_cmd_opts = function()
  return {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, location_result)
      local screencapture_location = location_result[1]
      render_msg.notify('screencapture available', vim.log.levels.INFO, {
        location = screencapture_location
      })
      M.location = screencapture_location
    end,
    on_stderr = function(_, result)
      if result[1] ~= nil and result[1] ~= '' then
        render_msg.notify('error getting screencapture file location', vim.log.levels.ERROR, result)
      end
    end,
  }
end

M.interrupt = function()
  for job_id, _ in pairs(M.job_ids) do
    local pid = vim.fn.jobpid(job_id)
    luv.kill(pid, 'sigint')
  end
  M.job_ids = {}
end

return M
