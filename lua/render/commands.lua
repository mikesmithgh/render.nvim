local render_core = require('render.core')
local render_screencapture = require('render.screencapture')
local render_constants = require('render.constants')
local render_fs = require('render.fs')
local render_fn = require('render.fn')
local render_windowinfo = require('render.windowinfo')
local render_api = require('render.api')
local M = {}

local opts = {}

---@param render_opts RenderOptions
M.setup = function(render_opts)
  opts = render_opts

  vim.api.nvim_create_user_command('Render', function(o)
    local profile_name = o.args
    if profile_name == nil or profile_name == '' then
      profile_name = 'default'
    end
    local profile = opts.profiles[profile_name]

    if profile == nil then
      opts.notify.msg('profile not found', vim.log.levels.ERROR, {
        profile_name = profile_name,
      })
      return
    end

    -- small delay to avoid capturing :Render command and flash
    vim.defer_fn(render_fn.partial(render_api.render, profile), 200)
  end, {
    nargs = '?',
    complete = function()
      return vim.tbl_keys(opts.profiles)
    end,
  })

  vim.api.nvim_create_user_command('RenderDryRun', render_api.render_dryrun, {})

  vim.api.nvim_create_user_command('RenderInterrupt', function()
    render_screencapture.interrupt()
  end, {})

  vim.api.nvim_create_user_command('RenderClean', function(o)
    render_api.render_clean({
      force = o.bang,
    })
  end, {
    bang = true,
  })

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

  vim.api.nvim_create_user_command('RenderSetWindowInfo', function(o)
    render_windowinfo.set_window_info(o.args)
  end, {
    nargs = '?',
  })
end

return M
