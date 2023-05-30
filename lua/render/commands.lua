local render_fn = require('render.fn')
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

    -- small delay to avoid capturing :Render command and flash
    vim.defer_fn(render_fn.partial(render_api.render, profile_name), 200)
  end, {
    nargs = '?',
    complete = function()
      return vim.tbl_keys(opts.profiles)
    end,
  })

  vim.api.nvim_create_user_command('RenderDryRun', function(o)
    local profile_name = o.args
    if profile_name == nil or profile_name == '' then
      profile_name = 'default'
    end
    render_api.dryrun(profile_name)
  end, {
    nargs = '?',
    complete = function()
      return vim.tbl_keys(opts.profiles)
    end,
  })


  vim.api.nvim_create_user_command('RenderInterrupt', render_api.interrupt, {})

  vim.api.nvim_create_user_command('RenderClean', function(o)
    render_api.clean({
      force = o.bang,
    })
  end, {
    bang = true,
  })

  vim.api.nvim_create_user_command('RenderQuickfix', render_api.quickfix, {})

  vim.api.nvim_create_user_command('RenderQuicklook', render_api.quicklook, {})

  vim.api.nvim_create_user_command('RenderExplore', render_api.explore, {})

  vim.api.nvim_create_user_command('RenderSetWindowInfo', function(o)
    render_api.set_window_info(o.args)
  end, {
    nargs = '?',
  })
end

return M
