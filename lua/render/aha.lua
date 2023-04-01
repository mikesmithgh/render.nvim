local M = {}
local render_msg = require('render.msg')

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
    '--css',
    opts.files.render_css,
    '-f',
    files.cat,
  }
end

M.cmd_opts = function(files)
  return {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, aha_result)
      vim.fn.writefile(aha_result, files.html)

      -- render png
      vim.fn.jobstart(
        opts.fn.playwright.cmd(),
        opts.fn.playwright.opts({
          input = files.html,
          output = files.file,
          type = 'png',
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
