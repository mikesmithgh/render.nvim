local render_fn = require('render.fn')
local luv = vim.loop
local M = {
  job_ids = {},
  timers = {},
}

local render_constants = require('render.constants')

local opts = {}

local function open_countdown_timer(delay)
  local buffer_id = vim.api.nvim_create_buf(false, true)
  local window_id = vim.api.nvim_open_win(buffer_id, false, opts.ui.countdown_window_opts())

  -- float window with warning highlighting
  local render_timer_ns = vim.api.nvim_create_namespace('render_timer')
  vim.api.nvim_win_set_hl_ns(window_id, render_timer_ns)
  local normal_float_hl = vim.api.nvim_get_hl(0, { name = 'NormalFloat' })
  local comment_hl = vim.api.nvim_get_hl(0, { name = 'WarningMsg' })
  local timer_hl = vim.tbl_extend('force', normal_float_hl, comment_hl)
  vim.api.nvim_set_hl(render_timer_ns, 'Normal', timer_hl)

  vim.api.nvim_buf_set_lines(buffer_id, 0, 4, false, {})
  vim.api.nvim_buf_set_lines(
    buffer_id,
    0,
    0,
    false,
    { '', '   render.nvim', '', '        ' .. tostring(delay) }
  )

  if delay - 1 <= 0 then
    M.timers[buffer_id] = nil
  else
    M.timers[buffer_id] = {
      count = delay - 1,
    }
  end

  local timer_id = vim.fn.timer_start(1000, function(tid)
    if M.timers[buffer_id] == nil then
      vim.api.nvim_buf_delete(buffer_id, { force = true })
      vim.fn.timer_stop(tid)
    else
      vim.api.nvim_buf_set_lines(buffer_id, 0, 4, false, {})
      vim.api.nvim_buf_set_lines(
        buffer_id,
        0,
        0,
        false,
        { '', '   render.nvim', '', '        ' .. tostring(M.timers[buffer_id].count) }
      )
      M.timers[buffer_id].count = M.timers[buffer_id].count - 1
      if M.timers[buffer_id].count < 1 then
        M.timers[buffer_id] = nil
      end
    end
  end, {
    ['repeat'] = delay,
  })

  if M.timers[buffer_id] ~= nil then
    M.timers[buffer_id].timer_id = timer_id
  end
end

M.setup = function(render_opts)
  opts = render_opts
end

M.cmd = function(x, y, width, height, out_files, mode_opts)
  local screencapture_cmd = { 'screencapture' }
  local mode = render_constants.screencapture.mode
  local type = render_constants.screencapture.type

  if mode_opts.dry_run then
    -- no operation is used for troubleshooting
    local screencapture_dryrun_script =
      vim.api.nvim_get_runtime_file('scripts/screencapture_dryrun.sh', false)[1]
    if screencapture_dryrun_script == nil then
      opts.notify.msg(
        'error getting screencapture dryrun script from runtime path',
        vim.log.levels.ERROR,
        {}
      )
      return
    end
    screencapture_cmd = { screencapture_dryrun_script }
  end

  table.insert(screencapture_cmd, '-R' .. x .. ',' .. y .. ',' .. width .. ',' .. height)

  if mode_opts.delay ~= nil then
    -- take the capture after a delay of <seconds>
    table.insert(screencapture_cmd, '-T' .. mode_opts.delay)
    if mode_opts.delay > 0 then
      open_countdown_timer(mode_opts.delay)
    end
  end

  if mode_opts.mode == mode.open then
    -- screen capture output will open in Preview or QuickTime Player if video
    table.insert(screencapture_cmd, '-P')
    out_files = vim.tbl_map(function()
      return "''"
    end, out_files)
  end

  if mode_opts.mode == mode.clipboard then
    -- force screen capture to go to the clipboard
    table.insert(screencapture_cmd, '-c')
  end

  if mode_opts.mode == mode.preview then
    -- present UI after screencapture is complete. files passed to command line will be ignored
    table.insert(screencapture_cmd, '-u')
    out_files = vim.tbl_map(function()
      return "''"
    end, out_files)
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

    if mode_opts.filetype == render_constants.psd then
      return vim.list_extend(screencapture_cmd, {
        '-tpsd',
        out_files.psd,
      })
    end

    if mode_opts.filetype == render_constants.bmp then
      return vim.list_extend(screencapture_cmd, {
        '-tbmp',
        out_files.bmp,
      })
    end

    if mode_opts.filetype == render_constants.tga then
      return vim.list_extend(screencapture_cmd, {
        '-ttga',
        out_files.tga,
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

  opts.notify.msg('unrecognized mode options', vim.log.levels.INFO, mode_opts)
  return nil
end

local function screencapture_cmd_tostring(mode_opts, screencapture_cmd)
  if screencapture_cmd == nil or next(screencapture_cmd) == nil then
    return ''
  end

  local screencapture_cmd_str = nil
  if screencapture_cmd ~= nil then
    for i, s in pairs(screencapture_cmd) do
      if i == 1 then
        screencapture_cmd_str = s
        if mode_opts.dry_run then
          screencapture_cmd_str = 'screencapture'
        end
      else
        screencapture_cmd_str = screencapture_cmd_str .. ' ' .. s
      end
    end
  end

  return render_fn.trim(screencapture_cmd_str)
end

M.cmd_opts = function(out_files, mode_opts, screencapture_cmd)
  local mode = render_constants.screencapture.mode
  local screencapture_cmd_str = screencapture_cmd_tostring(mode_opts, screencapture_cmd)
  return {
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(job_id, exit_code, _)
      if exit_code == 0 then
        if opts.features.flash then
          opts.fn.flash()
        end
        local msg = nil
        if mode_opts.mode == nil or mode_opts.mode == mode.save then
          local out_file = out_files[mode_opts.filetype]
          if opts.features.auto_open then
            local open_cmd = opts.fn.open_cmd()
            if open_cmd ~= nil then
              table.insert(open_cmd, out_file)
              vim.fn.jobstart(open_cmd)
            end
          end
          if opts.features.auto_preview then
            vim.fn.jobstart('qlmanage -p ' .. out_file, {
              cwd = opts.dirs.output,
            })
          end
          msg = { location = out_file }
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
              opts.fn.screencapture_location.opts({
                cmd = screencapture_cmd_str,
              })
            )
          end
        end

        if msg ~= nil then
          msg['cmd'] = screencapture_cmd_str
          msg['details'] = 'using render.nvim output location'
          opts.notify.msg('screencapture available', vim.log.levels.INFO, msg)
        end

        -- refresh quickfix list
        local qflist = vim.fn.getqflist({ title = true, idx = 0 })
        if qflist.title == render_constants.longname then
          local qfidx = qflist.idx
          if qfidx > 1 then
            render_fn.render_quickfix({
              cb = render_fn.partial(vim.cmd, 'cc ' .. qfidx + 1),
              toggle = false,
            })
          else
            render_fn.render_quickfix({ toggle = false })
          end
        end

        M.job_ids[job_id] = nil
      end
    end,
    on_stderr = function(job_id, result)
      if result[1] ~= nil and result[1] ~= '' then
        opts.notify.msg('error taking screencapture', vim.log.levels.ERROR, result)
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

M.location_cmd_opts = function(msg)
  if msg == nil then
    msg = {}
  end
  return {
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(_, exit_code, _)
      if exit_code ~= 0 then
        opts.notify.msg(
          'screencapture available',
          vim.log.levels.INFO,
          vim.tbl_extend('force', msg, {
            location = render_constants.screencapture.default_location,
            details = 'failed to read macos default screencapture location; defaulting location to '
              .. render_constants.screencapture.default_location,
          })
        )
        M.location = render_constants.screencapture.default_location
      end
    end,
    on_stdout = function(_, location_result)
      local screencapture_location = location_result[1]
      if screencapture_location ~= nil and screencapture_location ~= '' then
        opts.notify.msg(
          'screencapture available',
          vim.log.levels.INFO,
          vim.tbl_extend('force', msg, {
            location = screencapture_location,
            details = 'using macos default screencapture location',
          })
        )
        M.location = screencapture_location
      end
    end,
    on_stderr = function(_, result)
      if result[1] ~= nil and result[1] ~= '' then
        opts.notify.msg('error getting screencapture file location', vim.log.levels.DEBUG, result)
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
  for buffer_id, timer in pairs(M.timers) do
    vim.api.nvim_buf_delete(buffer_id, { force = true })
    vim.fn.timer_stop(timer.timer_id)
  end
  M.timers = {}
end

return M
