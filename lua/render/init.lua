local render_commands = require('render.commands')
local render_constants = require('render.constants')
local render_config = require('render.config')
local render_core = require('render.core')
local render_fn = require('render.fn')
local render_fs = require('render.fs')
local render_keymaps = require('render.keymaps')
local render_msg = require('render.msg')
local render_windowinfo = require('render.windowinfo')
local render_screencapture = require('render.screencapture')

local M = {}

M.setup = function(override_opts)
  M.default_opts = render_config.default_opts()
  if override_opts == nil then
    override_opts = {}
  end
  render_config.opts = vim.tbl_deep_extend('force', M.default_opts, override_opts)
  M.opts = render_config.opts

  render_msg.setup(M.opts)
  local os = render_fn.os()
  if os ~= 'mac' then
    M.opts.notify.msg(render_constants.longname .. ' is only compatible with macOS', vim.log.levels.ERROR, {
      os = os,
    })
    return
  end

  render_windowinfo.setup(M.opts)
  render_screencapture.setup(M.opts)
  render_fn.setup(M.opts)
  render_fs.setup(M.opts)
  render_keymaps.setup(M.opts)
  render_core.setup(M.opts)
  render_commands.setup(M.opts)
end

return M
