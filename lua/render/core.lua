local M = {}
local render_msg = require('render.msg')
local render_fs = require('render.fs')

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
end

local function new_output_files()
  local cur_name = vim.fn.expand('%:t')
  if cur_name == nil or cur_name == '' then
    cur_name = 'noname'
  end
  local normalized_name = vim.fn.substitute(cur_name, '\\W', '', 'g')
  local temp = vim.fn.tempname()
  local temp_prefix = vim.fn.fnamemodify(temp, ':h:t')
  local temp_name = vim.fn.fnamemodify(temp, ':t')
  local out_file = opts.dirs.output
    .. '/'
    .. temp_prefix
    .. '-'
    .. temp_name
    .. '-'
    .. normalized_name
  return {
    file = out_file,
    cat = out_file .. '.cat',
    html = out_file .. '.html',
    png = out_file .. '.png',
  }
end

M.render = function()
  local out_files = new_output_files()

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

    -- parse and remove dimensions of the screenshot
    local first_line = screenshot[1]
    local dimensions = vim.fn.split(first_line, ',')
    local height = dimensions[1]
    local width = dimensions[2]
    if height ~= nil and height ~= '' and width ~= nil and width ~= '' then
      table.remove(screenshot, 1)
      render_msg.notify('screenshot dimensions', vim.log.levels.DEBUG, {
        height = height,
        width = width,
      })
    end
    vim.fn.writefile(screenshot, out_files.cat)

    -- render html
    vim.fn.jobstart(opts.fn.aha.cmd(out_files), opts.fn.aha.opts(out_files))
  end)
end

return M
