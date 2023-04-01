local render_core = require('render.core')
local render_fn = require('render.fn')
local render_fs = require('render.fs')
local M = {}

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
  vim.api.nvim_create_user_command('Render', function()
    -- small delay to avoid capturing :Render command and flash
    vim.defer_fn(render_core.render, 200)
  end, {})

  vim.api.nvim_create_user_command('RenderClean', function()
    render_fs.remove_dirs(opts.dirs)
    render_fs.setup_files_and_dirs()
  end, {})

  vim.api.nvim_create_user_command('RenderQuickfix', function()
    vim.cmd.vimgrep({
      args = { '/\\%^/j ' .. opts.dirs.output .. '/*' },
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
        output = opts.dirs.output,
      })
    else
      vim.fn.setqflist(render_qflist)
      vim.cmd.copen()
    end
  end, {})

  vim.api.nvim_create_user_command('RenderOpen', function()
    vim.cmd.edit(opts.dirs.output)
  end, {})
end

return M
