local M = {}
local render_msg = require('render.msg')

local opts = {}

M.setup = function(render_opts)
  opts = render_opts
end


M.cmd = function()
  return {
    'npx',
    'playwright',
    'test',
    '--browser',
    'chromium',
    '--config',
    vim.fn.fnamemodify(opts.files.render_script, ':h'),
    opts.files.render_script,
  }
end

M.cmd_opts = function(playwright_opts)
  return {
    stdout_buffered = true,
    stderr_buffered = true,
    env = {
      RENDERNVIM_INPUT = playwright_opts.input,
      RENDERNVIM_OUTPUT = playwright_opts.output,
      RENDERNVIM_TYPE = playwright_opts.type,
    },
    on_exit = function(_, exit_code)
      local details = vim.tbl_extend(
        'force',
        playwright_opts,
        { output = playwright_opts.output .. '.' .. playwright_opts.type }
      )
      if exit_code == 0 then
        render_msg.notify('screenshot available', vim.log.levels.INFO, details)
        if opts.features.auto_open then
          local open_cmd = opts.fn.open_cmd()
          if open_cmd ~= nil then
            table.insert(open_cmd, details.output)
            vim.fn.jobstart(open_cmd)
          end
        end
      else
        render_msg.notify('failed to generate screenshot', vim.log.levels.WARN, details)
      end
    end,
    on_stderr = function(_, result)
      if result[1] ~= nil and result[1] ~= '' then
        render_msg.notify('error generating screenshot', vim.log.levels.ERROR, result)
      end
    end,
  }
end

return M
