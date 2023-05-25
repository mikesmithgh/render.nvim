local render_core = require('render.core')
local render_screencapture = require('render.screencapture')
local render_constants = require('render.constants')
local render_fs = require('render.fs')
local render_fn = require('render.fn')
local render_windowinfo = require('render.windowinfo')
local M = {}

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
  vim.api.nvim_create_user_command('Render', function(o)
    local filetype = o.args
    local mode_opts = opts.mode_opts
    if filetype ~= nil and filetype ~= '' then
      if not vim.tbl_contains(render_constants.all_types, filetype) then
        -- TODO: error
        return
      end
      mode_opts = vim.tbl_extend('force', opts.mode_opts, {
        type = render_constants.screencapture.type.image,
        filetype = filetype,
      })
      if vim.tbl_contains(render_constants.video_types, filetype) then
        mode_opts = vim.tbl_extend('force', opts.mode_opts, {
          type = render_constants.screencapture.type.video,
          filetype = filetype,
        })
      end
    end
    -- small delay to avoid capturing :Render command and flash
    vim.defer_fn(render_fn.partial(render_core.render, mode_opts), 200)
  end, {
    nargs = '?',
    complete = function()
      return render_constants.all_types
    end,
  })

  vim.api.nvim_create_user_command('RenderDryRun', render_core.render_dryrun, {})

  vim.api.nvim_create_user_command('RenderInterrupt', function()
    render_screencapture.interrupt()
  end, {})

  vim.api.nvim_create_user_command('RenderClean', function()
    render_fs.remove_dirs(opts.dirs)
    render_fs.setup_files_and_dirs()
  end, {})

  vim.api.nvim_create_user_command(
    'RenderQuickfix',
    render_fn.partial(render_fn.render_quickfix, { cb = vim.cmd.copen, toggle = true }),
    {}
  )

  vim.api.nvim_create_user_command('RenderQuicklook', function()
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
  end, {})

  vim.api.nvim_create_user_command('RenderExplore', function()
    vim.cmd.edit(opts.dirs.output)
  end, {})

  vim.api.nvim_create_user_command('RenderSetWindowInfo',
    function(o)
      render_windowinfo.set_window_info(o.args)
    end, {
      nargs = '?',
    })
end

return M
