local M = {}

local shortname = "render"
local longname = "render.nvim"

local function render_notify(msg, level, extra)
  if M.opts.notify_enabled then
    vim.notify(
      vim.inspect(vim.tbl_extend("keep", { msg = string.format("%s: %s", longname, msg), }, extra)),
      level,
      {}
    )
  end
end

local standard_opts = {
  aha_command = function(files, opts)
    if files.cat == nil or files.cat == "" then
      return
    end
    if opts.resources.font == nil or opts.resources.font == "" then
      return
    end

    return {
      "aha",
      '--css',
      opts.resources.font,
      '-f',
      files.cat,
    }
  end,
  phantomjs = {
    cmd = function(script, input, output)
      return {
        "phantomjs",
        script,
        input,
        output,
      }
    end,
    opts = function(filein, fileout)
      return {
        on_exit = function(_, exit_code)
          if exit_code == 0 then
            render_notify("screenshot available", vim.log.levels.INFO, {
              input = filein,
              output = fileout,
            })
          else
            render_notify("failed to generate screenshot", vim.log.levels.WARN, {
              input = filein,
              output = fileout,
            })
          end
        end
      }
    end
  },
  dirs = {
    data = vim.fn.stdpath("data") .. "/" .. shortname,
    state = vim.fn.stdpath("state") .. "/" .. shortname,
    run = vim.fn.stdpath("run") .. "/" .. shortname,
    output = vim.fn.stdpath("data") .. "/" .. shortname .. "/output",
  },
  resources = {
    font = vim.api.nvim_get_runtime_file("resources/render/font.css", false)[1],
    rasterizejs = vim.api.nvim_get_runtime_file("resources/render/rasterize.js", false)[1],
  },
  notify_enabled = true,
  keymaps_enabled = true,
  keymap_setup = function()
    -- <f13> == <shift-f1> == print screen
    vim.keymap.set({ 'n', 'i', 'c', 'v', 'x', 's', 'o', 't', 'l' }, '<f13>', M.render, { silent = true, remap = true })
  end
}

local function new_output_files()
  local cur_name = vim.fn.expand("%:t")
  if cur_name == nil or cur_name == "" then
    cur_name = "noname"
  end
  local temp = vim.fn.tempname()
  local temp_dir = vim.fn.fnamemodify(temp, ":h:t")
  local temp_name = vim.fn.fnamemodify(temp, ":t")
  local out_dir = M.opts.dirs.output .. "/" .. temp_dir
  local out_file = out_dir .. "/" .. temp_name .. "." .. cur_name
  vim.fn.mkdir(out_dir, "p")
  return {
    dir = out_dir,
    file = out_file,
    cat = out_file .. ".cat",
    html = out_file .. ".html",
    png = out_file .. ".png",
  }
end

M.render = function()
  local out_files = new_output_files()

  -- WARNING undocumented nvim function this may have breaking changes in the future
  vim.api.nvim__screenshot(out_files.cat)

  local screenshot
  local retries = 6
  repeat
    vim.cmd.sleep("500ms")
    -- wait until screenshot has succesfully written to file
    local ok, file_content = pcall(vim.fn.readfile, out_files.cat)
    if ok and file_content ~= nil and file_content ~= "" then
      screenshot = file_content
      break
    end
  until retries == 0

  if screenshot == nil or next(screenshot) == nil then
    render_notify("error reading file", vim.log.levels.ERROR, {
      file = out_files.cat,
    })
    return
  end

  -- parse and remove dimensions of the screenshot
  local first_line = screenshot[1]
  local dimensions = vim.fn.split(first_line, ",")
  local height = dimensions[1]
  local width = dimensions[2]
  if height ~= nil and height ~= "" and width ~= nil and width ~= "" then
    table.remove(screenshot, 1)
    render_notify("screenshot dimensions", vim.log.levels.DEBUG, {
      height = height,
      width = width,
    })
  end
  vim.fn.writefile(screenshot, out_files.cat)

  -- render html
  vim.fn.jobstart(
    M.opts.aha_command(out_files, M.opts),
    {
      stdout_buffered = true,
      on_stdout = function(_, aha_result)
        vim.fn.writefile(aha_result, out_files.html)

        -- render png
        vim.fn.jobstart(
          M.opts.phantomjs.cmd(M.opts.resources.rasterizejs, out_files.html, out_files.png),
          M.opts.phantomjs.opts(out_files.html, out_files.png)
        )
      end
    })
end

M.remove_dirs = function()
  for _, dir in pairs(M.opts.dirs) do
    vim.fn.delete(dir, "rf")
  end
end

M.create_dirs = function()
  for _, dir in pairs(M.opts.dirs) do
    vim.fn.mkdir(dir, "p")
  end
end

M.opts = standard_opts

M.setup = function(override_opts)
  if override_opts == nil then
    override_opts = {}
  end
  M.opts = vim.tbl_extend("force", M.opts, override_opts)
  M.create_dirs()


  vim.api.nvim_create_user_command("Render", function()
    -- small delay to avoid capturing :Render command as its typed
    vim.defer_fn(M.render, 200)
  end, {})
  vim.api.nvim_create_user_command("RenderClean", function()
    M.remove_dirs()
    M.create_dirs()
  end, {})
  vim.api.nvim_create_user_command("RenderQuickfix", function()
    vim.cmd.vimgrep(
      {
        args = { "/\\%^/j " .. M.opts.dirs.output .. "/*/*" },
        mods = { emsg_silent = true }
      }
    )
    local render_qflist = vim.tbl_map(function(line)
      local description = {
        cat = "ANSI Escape Sequences",
        html = "HyperText Markup Language",
        png = "Portable Network Graphics",
      }
      local ext = vim.fn.fnamemodify(vim.fn.bufname(line.bufnr), ":e")
      line.text = description[ext]
      return line
    end, vim.fn.getqflist())
    if next(render_qflist) == nil then
      render_notify("no output files found", vim.log.levels.INFO, {
        output = M.opts.dirs.output
      })
    else
      vim.fn.setqflist(render_qflist)
      vim.cmd.copen()
    end
  end, {})
  vim.api.nvim_create_user_command("RenderOpen", function()
    vim.cmd.edit(M.opts.dirs.output)
  end, {})


  if M.opts.keymaps_enabled then
    M.opts.keymap_setup()
  end
end

return M
