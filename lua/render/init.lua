local render_fs = require('render.fs')
local render_fn = require('render.fn')
local render_msg = require('render.msg')
local render_config = require('render.config')
local render_aha = require('render.aha')
local render_playwright = require('render.playwright')
local M = {}

local function setup_commands()
  vim.api.nvim_create_user_command('Render', function()
    -- small delay to avoid capturing :Render command and flash
    vim.defer_fn(M.render, 200)
  end, {})

  vim.api.nvim_create_user_command('RenderClean', function()
    render_fs.remove_dirs(M.opts.dirs)
    render_fs.setup_files_and_dirs()
  end, {})

  vim.api.nvim_create_user_command('RenderQuickfix', function()
    vim.cmd.vimgrep({
      args = { '/\\%^/j ' .. M.opts.dirs.output .. '/*' },
      mods = { emsg_silent = true },
    })
    local render_qflist = vim.tbl_map(function(line)
      local description = {
        cat = 'ANSI Escape Sequences',
        html = 'HyperText Markup Language',
        png = 'Portable Network Graphics',
      }
      local ext = vim.fn.fnamemodify(vim.fn.bufname(line.bufnr), ':e')
      line.text = description[ext]
      return line
    end, vim.fn.getqflist())
    if next(render_qflist) == nil then
      render_fn.notify('no output files found', vim.log.levels.INFO, {
        output = M.opts.dirs.output,
      })
    else
      vim.fn.setqflist(render_qflist)
      vim.cmd.copen()
    end
  end, {})

  vim.api.nvim_create_user_command('RenderOpen', function()
    vim.cmd.edit(M.opts.dirs.output)
  end, {})
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
  local out_file = render_config.opts.dirs.output .. '/' .. temp_prefix .. '-' .. temp_name .. '-' .. normalized_name
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

  if M.opts.features.flash then
    M.opts.fn.flash()
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
    vim.fn.jobstart(M.opts.fn.aha.cmd(out_files), M.opts.fn.aha.opts(out_files))
  end)
end

M.setup = function(override_opts)
  M.default_opts = render_config.default_opts
  if override_opts == nil then
    override_opts = {}
  end
  render_config.opts = vim.tbl_deep_extend('force', M.default_opts, override_opts)
  M.opts = render_config.opts

  render_msg.setup(M.opts)
  render_aha.setup(M.opts)
  render_playwright.setup(M.opts)
  render_fs.setup(M.opts)
  render_fs.setup_files_and_dirs()
  setup_commands()
  if M.opts.features.keymaps then
    M.opts.fn.keymap_setup()
  end
end

return M
