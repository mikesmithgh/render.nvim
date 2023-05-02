local render_core = require('render.core')
local render_screencapture = require('render.screencapture')
local M = {}

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
  if opts.features.keymaps then
    opts.fn.keymap_setup()
  end
end

M.setup_default_keymaps = function()
  -- <f13> == <shift-f1> == print screen
  vim.keymap.set(
    { 'n', 'i', 'c', 'v', 'x', 's', 'o', 't', 'l' },
    '<f13>',
    render_core.render,
    { silent = true, remap = true }
  )

  -- <f13> == <shift-f1> == print screen
  vim.keymap.set(
    { 'n', 'i', 'c', 'v', 'x', 's', 'o', 't', 'l' },
    '<leader><f13>',
    render_screencapture.interrupt,
    { silent = true, remap = true }
  )
end

return M
