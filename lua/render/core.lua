local M = {}
local render_msg = require('render.msg')
local render_fs = require('render.fs')
local render_fn = require('render.fn')

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
end

M.render = function()
  local out_files = render_fn.new_output_files()

  -- WARNING undocumented nvim function this may have breaking changes in the future
  vim.api.nvim__screenshot(out_files.cat)

  if opts.features.flash then
    opts.fn.flash()
  end

  render_fs.wait_for_cat_file(out_files, function(screenshot)
    if screenshot == nil or next(screenshot) == nil then
      render_msg.notify('error reading file; screenshot is nil', vim.log.levels.ERROR, {
        file = out_files.cat,
      })
      return
    end
    local height, width = render_fn.sanitize_ansi_screenshot(screenshot)
    render_msg.notify('screenshot dimensions', vim.log.levels.DEBUG, {
      height = height,
      width = width,
    })
    vim.fn.writefile(screenshot, out_files.cat)

    -- convert ansi to html
    vim.fn.jobstart(opts.fn.aha.cmd(out_files), opts.fn.aha.opts(out_files))
  end)
end

return M
