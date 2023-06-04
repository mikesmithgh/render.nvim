---@mod render.commands Render Commands

local render_fn = require('render.fn')
local render_api = require('render.api')
local M = {}

---@type RenderOptions
local opts = {}

---@param render_opts RenderOptions
M.setup = function(render_opts)
  opts = render_opts

  ---@brief [[
  ---:Render {profilename}  Capture image or video recording.  If {profilename}
  ---                       is empty, it will use the value 'default'.
  ---                       {profilename} is passed as a `string` to
  ---                       |render.api.render|.
  ---    See: ~
  ---        |render.api.render|
  ---@brief ]]
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

  ---@brief [[
  ---:RenderDryRun {profilename}  Execute render logic without capturing result.
  ---                             If {profilename} is empty, it will use the
  ---                             value 'default'. {profilename} is passed as a
  ---                             `string` to |render.api.dryrun|.
  ---    See: ~
  ---        |render.api.dryrun|
  ---@brief ]]
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

  ---@brief [[
  ---:RenderClean[!]  Delete existing capture in output directory and reninstall
  ---                 dependencies. '!' forces clean without prompting for
  ---                 confirmation, equivalent to passing `{ force = true }` to
  ---                 |render.api.clean|.
  ---    See: ~
  ---        |render.api.clean|
  ---@brief ]]
  vim.api.nvim_create_user_command('RenderClean', function(o)
    render_api.clean({
      force = o.bang,
    })
  end, {
    bang = true,
  })

  ---@brief [[
  ---:RenderExplore  Open render output directory in neovim.
  ---
  ---    See: ~
  ---        |render.api.explore|
  ---@brief ]]
  vim.api.nvim_create_user_command('RenderExplore', render_api.explore, {})

  ---@brief [[
  ---:RenderQuickfix[!]  Toggle open output directory in quickfix window.
  ---                    '!' forces the quickfix window open without toggle,
  ---                    equivalent to passing `{ toggle = false }` to
  ---                    |render.api.quickfix|.
  ---    See: ~
  ---        |render.api.quickfix|
  ---@brief ]]
  vim.api.nvim_create_user_command('RenderQuickfix', function(o)
    render_api.quickfix({
      toggle = not o.bang,
    })
  end, {
    bang = true,
  })

  ---@brief [[
  ---:RenderInterrupt  Send interrupt to stop video recording.
  ---
  ---    See: ~
  ---        |render.api.interrupt|
  ---@brief ]]
  vim.api.nvim_create_user_command('RenderInterrupt', render_api.interrupt, {})

  ---@brief [[
  ---:RenderQuicklook  Open all files in output directory with quick look.
  ---
  ---    See: ~
  ---        |render.api.quicklook|
  ---@brief ]]
  vim.api.nvim_create_user_command('RenderQuicklook', render_api.quicklook, {})

  ---@brief [[
  ---:RenderSetWindowInfo {pid}  Set the window information to the active
  ---                            neovim session or by {pid}. If {pid} is
  ---                            empty, the `pid` of the neovim session
  ---                            will be used.
  ---
  ---    See: ~
  ---        |render.api.set_window_info|
  ---@brief ]]
  vim.api.nvim_create_user_command('RenderSetWindowInfo', function(o)
    render_api.set_window_info(o.args)
  end, {
    nargs = '?',
  })
end

return M
