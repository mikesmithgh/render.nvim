local render_core = require('render.core')
local render_screencapture = require('render.screencapture')
local render_msg = require('render.msg')
local render_fs = require('render.fs')
local render_fn = require('render.fn')
local render_constants = require('render.constants')
local M = {}

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
  vim.api.nvim_create_user_command('Render', function()
    -- small delay to avoid capturing :Render command and flash
    vim.defer_fn(render_core.render, 200)
  end, {})
  vim.api.nvim_create_user_command('RenderPng', function()
    vim.defer_fn(render_core.render_png, 200)
  end, {})
  vim.api.nvim_create_user_command('RenderJpg', function()
    vim.defer_fn(render_core.render_jpg, 200)
  end, {})
  vim.api.nvim_create_user_command('RenderGif', function()
    vim.defer_fn(render_core.render_gif, 200)
  end, {})
  vim.api.nvim_create_user_command('RenderTiff', function()
    vim.defer_fn(render_core.render_tiff, 200)
  end, {})
  vim.api.nvim_create_user_command('RenderPdf', function()
    vim.defer_fn(render_core.render_pdf, 200)
  end, {})
  vim.api.nvim_create_user_command('RenderPsd', function()
    vim.defer_fn(render_core.render_psd, 200)
  end, {})
  vim.api.nvim_create_user_command('RenderTga', function()
    vim.defer_fn(render_core.render_tga, 200)
  end, {})
  vim.api.nvim_create_user_command('RenderBmp', function()
    vim.defer_fn(render_core.render_bmp, 200)
  end, {})
  vim.api.nvim_create_user_command('RenderVideo', function()
    vim.defer_fn(render_core.render_video, 200)
  end, {})
  vim.api.nvim_create_user_command('RenderDryRun', render_core.render_dryrun, {})

  vim.api.nvim_create_user_command('RenderInterrupt', function()
    render_screencapture.interrupt()
  end, {})

  vim.api.nvim_create_user_command('RenderClean', function()
    render_fs.remove_dirs(opts.dirs)
    render_fs.setup_files_and_dirs()
  end, {})

  vim.api.nvim_create_user_command('RenderQuickfix',
    render_fn.partial(render_fn.render_quickfix, { cb = vim.cmd.copen, toggle = true })
    , {})

  vim.api.nvim_create_user_command('RenderQuicklook', function()
    vim.fn.jobstart(
      'stat -n -f "%N " * | xargs qlmanage -p',
      {
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
end

return M
