local render_fn = require('render.fn')
local render_cache = require('render.cache')
local M = {}

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
    render_cache.timers[buffer_id] = nil
  else
    render_cache.timers[buffer_id] = {
      count = delay - 1,
    }
  end

  local timer_id = vim.fn.timer_start(1000, function(tid)
    if render_cache.timers[buffer_id] == nil then
      vim.api.nvim_buf_delete(buffer_id, { force = true })
      vim.fn.timer_stop(tid)
    else
      vim.api.nvim_buf_set_lines(buffer_id, 0, 4, false, {})
      vim.api.nvim_buf_set_lines(
        buffer_id,
        0,
        0,
        false,
        { '', '   render.nvim', '', '        ' .. tostring(render_cache.timers[buffer_id].count) }
      )
      render_cache.timers[buffer_id].count = render_cache.timers[buffer_id].count - 1
      if render_cache.timers[buffer_id].count < 1 then
        render_cache.timers[buffer_id] = nil
      end
    end
  end, {
    ['repeat'] = delay,
  })

  if render_cache.timers[buffer_id] ~= nil then
    render_cache.timers[buffer_id].timer_id = timer_id
  end
end

---@param render_opts RenderOptions
M.setup = function(render_opts)
  opts = render_opts
end

---comment
---@param wid integer
---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param out_files table
---@param profile ProfileOptions
---@return nil
M.cmd = function(wid, x, y, width, height, out_files, profile)
  local screencapture_cmd = { 'screencapture' }
  local mode = render_constants.screencapture.mode
  local capturemode = render_constants.screencapture.capturemode
  local type = render_constants.screencapture.type
  local filetype = profile.filetype
  local is_video = vim.tbl_contains(render_constants.video_types, filetype)

  if profile.dry_run then
    -- no operation is used for troubleshooting
    local screencapture_dryrun_script =
      vim.api.nvim_get_runtime_file('scripts/screencapture_dryrun.sh', false)[1]
    if screencapture_dryrun_script == nil then
      opts.notify.msg(
        'error getting screencapture dryrun script from runtime path',
        vim.log.levels.ERROR,
        {}
      )
      return nil
    end
    screencapture_cmd = { screencapture_dryrun_script }
  end

  -- video does not support capture by window ID
  if is_video or profile.image_capture_mode == capturemode.bounds then
    table.insert(screencapture_cmd, '-R' .. x .. ',' .. y .. ',' .. width .. ',' .. height)
  elseif profile.image_capture_mode == capturemode.window then
    table.insert(screencapture_cmd, '-l' .. wid)
  else
    opts.notify.msg('unrecognized capturemode options', vim.log.levels.ERROR, profile)
    return nil
  end

  if not opts.features.sound_effect then
    table.insert(screencapture_cmd, '-x')
  end

  if not profile.window_shadow then
    table.insert(screencapture_cmd, '-o')
  end

  if profile.delay ~= nil then
    -- take the capture after a delay of <seconds>
    table.insert(screencapture_cmd, '-T' .. profile.delay)
    if profile.delay > 0 then
      open_countdown_timer(profile.delay)
    end
  end

  if profile.mode == mode.open then
    -- screen capture output will open in Preview or QuickTime Player if video
    table.insert(screencapture_cmd, '-P')
    out_files = vim.tbl_map(function()
      return "''"
    end, out_files)
  end

  if profile.mode == mode.clipboard then
    -- force screen capture to go to the clipboard
    table.insert(screencapture_cmd, '-c')
  end

  if profile.mode == mode.preview then
    -- present UI after screencapture is complete. files passed to command line will be ignored
    table.insert(screencapture_cmd, '-u')
    out_files = vim.tbl_map(function()
      return "''"
    end, out_files)
  end

  if profile.type == nil or profile.type == type.image then
    if filetype == nil or filetype == render_constants.png then
      return vim.list_extend(screencapture_cmd, {
        '-tpng',
        out_files.png,
      })
    end

    if filetype == render_constants.jpg then
      return vim.list_extend(screencapture_cmd, {
        '-tjpg',
        out_files.jpg,
      })
    end

    if filetype == render_constants.gif then
      return vim.list_extend(screencapture_cmd, {
        '-tgif',
        out_files.gif,
      })
    end

    if filetype == render_constants.pdf then
      return vim.list_extend(screencapture_cmd, {
        '-tpdf',
        out_files.pdf,
      })
    end

    if filetype == render_constants.psd then
      return vim.list_extend(screencapture_cmd, {
        '-tpsd',
        out_files.psd,
      })
    end

    if filetype == render_constants.bmp then
      return vim.list_extend(screencapture_cmd, {
        '-tbmp',
        out_files.bmp,
      })
    end

    if filetype == render_constants.tga then
      return vim.list_extend(screencapture_cmd, {
        '-ttga',
        out_files.tga,
      })
    end

    if filetype == render_constants.tiff then
      return vim.list_extend(screencapture_cmd, {
        '-ttiff',
        out_files.tiff,
      })
    end
  end

  if is_video then
    if profile.show_clicks then
      -- show clicks in video recording mode
      table.insert(screencapture_cmd, '-k')
    end

    return vim.list_extend(screencapture_cmd, {
      '-v',
      out_files.mov,
    })
  end

  opts.notify.msg('unrecognized mode options', vim.log.levels.ERROR, profile)
  return nil
end

---comment
---@param profile ProfileOptions
---@param screencapture_cmd table
---@return string
local function screencapture_cmd_tostring(profile, screencapture_cmd)
  if screencapture_cmd == nil or next(screencapture_cmd) == nil then
    return ''
  end

  local screencapture_cmd_str = nil
  if screencapture_cmd ~= nil then
    for i, s in pairs(screencapture_cmd) do
      if i == 1 then
        screencapture_cmd_str = s
        if profile.dry_run then
          screencapture_cmd_str = 'screencapture'
        end
      else
        screencapture_cmd_str = screencapture_cmd_str .. ' ' .. s
      end
    end
  end

  return render_fn.trim(screencapture_cmd_str)
end

---comment
---@param out_files table
---@param profile ProfileOptions
---@param screencapture_cmd string
---@return table
M.cmd_opts = function(out_files, profile, screencapture_cmd)
  local mode = render_constants.screencapture.mode
  local screencapture_cmd_str = screencapture_cmd_tostring(profile, screencapture_cmd)
  return {
    stdout_buffered = true,
    stderr_buffered = true,
    on_exit = function(job_id, exit_code, _)
      if exit_code == 0 then
        if opts.features.flash then
          opts.fn.flash()
        end
        local msg = nil
        if profile.mode == nil or profile.mode == mode.save then
          local out_file = out_files[profile.filetype]
          if opts.features.auto_open and not profile.dry_run then
            local open_cmd = opts.fn.open_cmd()
            if open_cmd ~= nil then
              table.insert(open_cmd, out_file)
              vim.fn.jobstart(open_cmd)
            end
          end
          if opts.features.auto_preview and not profile.dry_run then
            vim.fn.jobstart('qlmanage -p ' .. out_file, {
              cwd = opts.dirs.output,
            })
          end
          msg = { location = out_file }
        end
        if profile.mode == mode.clipboard then
          msg = { location = mode.clipboard }
        end
        if profile.mode == mode.preview or profile.mode == mode.open then
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

        render_cache.job_ids[job_id] = nil
      end
    end,
    on_stderr = function(job_id, result)
      if result[1] ~= nil and result[1] ~= '' then
        opts.notify.msg('error taking screencapture', vim.log.levels.ERROR, result)
      end
      render_cache.job_ids[job_id] = nil
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

return M
