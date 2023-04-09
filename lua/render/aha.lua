local M = {}
local render_msg = require('render.msg')
local render_constants = require('render.constants')

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
end

M.cmd = function(files)
  if files.cat == nil or files.cat == '' then
    return
  end
  return {
    'aha',
    '--no-header',
    '-f',
    files.cat,
  }
end

M.cmd_opts = function(files)
  return {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, aha_result)
      vim.fn.writefile({
        '<!DOCTYPE html>',
        '<!-- This file was generated with render.nvim (https://github.com/mikesmithgh/render.nvim) -->',
        '<!-- by using aha Ansi HTML Adapter (https://github.com/theZiz/aha) Thanks aha authors! :) -->',
        '<html>',
        '<head>',
        '<title>render.nvim</title>',
        '<style>',
      }, files.html)
      local css = vim.fn.readfile(opts.files.render_css)
      vim.fn.writefile(css, files.html, 'ab')
      vim.fn.writefile({
        '</style>',
        '</head>',
        '<body>',
        '<pre>',
      }, files.html, 'ab')
      vim.fn.writefile(aha_result, files.html, 'ab')
      vim.fn.writefile({
        '</pre>',
        '</body>',
        '</html>',
      }, files.html, 'a')

      -- render png
      vim.fn.jobstart(
        opts.fn.playwright.cmd(),
        opts.fn.playwright.opts({
          input = files.html,
          output = files.file,
          type = render_constants.png,
        })
      )
    end,
    on_stderr = function(_, result)
      if result[1] ~= nil and result[1] ~= '' then
        render_msg.notify('error generating html', vim.log.levels.ERROR, result)
      end
    end,
  }
end

return M
