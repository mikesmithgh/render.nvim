local render_api = require('render.api')
local render_screencapture = require('render.screencapture')
local render_fn = require('render.fn')
local M = {}

---@type RenderOptions
local opts = {}

---@param render_opts RenderOptions
M.setup = function(render_opts)
  opts = render_opts
  if opts.features.keymaps then
    opts.fn.keymap_setup()
  end
end

---Setup default keymaps
--- <f13> == <shift-f1> == print screen
M.setup_default_keymaps = function()
  vim.keymap.set(
    { 'n', 'i', 'c', 'v', 'x', 's', 'o', 't', 'l' },
    '<f13>',
    render_api.render,
    { silent = true, remap = true }
  )

  vim.keymap.set({ 'n' }, '<leader><f13>', render_api.interrupt, { silent = true, remap = true })

  vim.keymap.set({ 'n' }, '<C-f13>', render_api.quickfix, { silent = true, remap = true })

  vim.keymap.set({ 'n' }, '<cr>', render_fn.partial(render_fn.open_qfitem, '<cr>'), {
    silent = true,
    expr = true,
    replace_keycodes = true,
  })

  vim.keymap.set({ 'n' }, '<c-w><cr>', render_fn.partial(render_fn.open_qfitem, '<c-w><cr>'), {
    silent = true,
    expr = true,
    replace_keycodes = true,
  })

  vim.keymap.set({ 'n' }, '<tab>', render_fn.partial(render_fn.quicklook_qfitem, '<tab>'), {
    silent = true,
    expr = true,
    replace_keycodes = true,
  })
end

return M
