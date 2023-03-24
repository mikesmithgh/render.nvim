local renderfs = require("render.fs")

local M = {}

-- thank you nvimtree.nvim for os logic
M.is_unix = vim.fn.has "unix" == 1
M.is_macos = vim.fn.has "mac" == 1 or vim.fn.has "macunix" == 1
M.is_wsl = vim.fn.has "wsl" == 1
-- false for WSL
M.is_windows = vim.fn.has "win32" == 1 or vim.fn.has "win32unix" == 1

local shortname = "render"
local longname = "render.nvim"

local function render_notify(msg, level, extra)
  if M.opts.features.notify then
    vim.notify(
      vim.inspect(vim.tbl_extend("keep", { msg = string.format("%s: %s", longname, msg), }, extra)),
      level,
      {}
    )
  end
end

local standard_opts = {
  features = {
    notify = true,
    keymaps = true,
    flash = true,
    auto_open = true,
  },
  fn = {
    aha = {
      cmd = function(files)
        if files.cat == nil or files.cat == "" then
          return
        end
        return {
          "docker",
          "run",
          "--ipc=host",
          "--user=pwuser",
          "--security-opt",
          "seccomp=/Users/mike/gitrepos/render.nvim/lua/render/seccomp_profile.json",
          "-v",
          M.opts.dirs.runtime_render_plugin_dir .. ":" .. M.opts.dirs.runtime_render_plugin_dir,
          "-v",
          M.opts.dirs.data .. ":" .. M.opts.dirs.data,
          "-v",
          M.opts.dirs.state .. ":" .. M.opts.dirs.state,
          "mikesmithgh/render.nvim",
          "aha",
          '--css',
          M.opts.files.render_css,
          '-f',
          files.cat,
        }
      end,
      opts = function(files)
        return {
          stdout_buffered = true,
          stderr_buffered = true,
          on_stdout = function(_, aha_result)
            vim.fn.writefile(aha_result, files.html)

            local playwright_opts = {
              input = files.html,
              output = files.file,
              type = 'png',
            }
            -- render png
            vim.fn.jobstart(M.opts.fn.playwright.cmd(playwright_opts), M.opts.fn.playwright.opts(playwright_opts)
            )
          end,
          on_stderr = function(_, result)
            if result[1] ~= nil and result[1] ~= "" then
              render_notify("error generating html", vim.log.levels.ERROR, result)
            end
          end,
        }
      end
    },
    playwright = {
      cmd = function(playwright_opts)
        return {
          "docker",
          "run",
          "--ipc=host",
          "--user=pwuser",
          "--security-opt",
          "seccomp=/Users/mike/gitrepos/render.nvim/lua/render/seccomp_profile.json",
          "-v",
          M.opts.dirs.runtime_render_plugin_dir .. ":" .. M.opts.dirs.runtime_render_plugin_dir,
          "-v",
          M.opts.dirs.data .. ":" .. M.opts.dirs.data,
          "-v",
          M.opts.dirs.state .. ":" .. M.opts.dirs.state,
          "-e",
          "RENDERNVIM_INPUT=" .. playwright_opts.input,
          "-e",
          "RENDERNVIM_OUTPUT=" .. playwright_opts.output,
          "-e",
          "RENDERNVIM_TYPE=" .. playwright_opts.type,
          "mikesmithgh/render.nvim",
          "npx",
          "playwright",
          "test",
          "--output",
          "/tmp/playwright/test-results",
          "--browser",
          "chromium",
          "--config",
          vim.fn.fnamemodify(M.opts.files.render_script, ":h"),
          M.opts.files.render_script,
        }
      end,
      opts = function(playwright_opts)
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
              "force",
              playwright_opts,
              { output = playwright_opts.output .. "." .. playwright_opts.type, }
            )
            if exit_code == 0 then
              render_notify("screenshot available", vim.log.levels.INFO, details)
              if M.opts.features.auto_open then
                local open_cmd = M.opts.fn.open_cmd()
                table.insert(open_cmd, details.output)
                vim.fn.jobstart(open_cmd)
              end
            else
              render_notify("failed to generate screenshot", vim.log.levels.WARN, details)
            end
          end,
          on_stderr = function(_, result)
            if result[1] ~= nil and result[1] ~= "" then
              render_notify("error generating screenshot", vim.log.levels.ERROR, result)
            end
          end,
        }
      end
    },
    keymap_setup = function()
      -- <f13> == <shift-f1> == print screen
      vim.keymap.set({ 'n', 'i', 'c', 'v', 'x', 's', 'o', 't', 'l' }, '<f13>', M.render, { silent = true, remap = true })
    end,
    flash = function()
      local render_ns = vim.api.nvim_create_namespace('render')
      local normal_hl = vim.api.nvim_get_hl_by_name("CursorLine", true)
      local flash_color = normal_hl.background
      if flash_color == nil or flash_color == "" then
        flash_color = "#000000"
        if vim.opt.bg:get() == "dark" then
          flash_color = "#ffffff"
        end
      end
      vim.api.nvim_set_hl(render_ns, "Normal", { fg = flash_color, bg = flash_color })
      vim.api.nvim_set_hl_ns(render_ns)
      vim.cmd.mode()
      vim.defer_fn(function()
        vim.api.nvim_set_hl_ns(0)
        vim.cmd.mode()
      end, 100)
    end,
    open_cmd = function()
      -- thank you nvimtree.nvim for open logic
      if M.is_windows then
        return {
          cmd = "cmd",
          args = { "/c", "start", '""' },
        }
      elseif M.is_macos then
        return { "open" }
      elseif M.is_unix then
        return { "xdg-open" }
      end
      return {}
    end,
  },
  dirs = {
    data = vim.fn.stdpath("data") .. "/" .. shortname,
    state = vim.fn.stdpath("state") .. "/" .. shortname,
    run = vim.fn.stdpath("run") .. "/" .. shortname,
    output = vim.fn.stdpath("data") .. "/" .. shortname .. "/output",
    css = vim.fn.stdpath("data") .. "/" .. shortname .. "/css",
    font = vim.fn.stdpath("data") .. "/" .. shortname .. "/font",
    scripts = vim.fn.stdpath("data") .. "/" .. shortname .. "/scripts",
    runtime_render_plugin_dir = vim.tbl_filter(
      function(p) return p:match('^(.*)' .. longname .. '$') end,
      vim.api.nvim_list_runtime_paths()
    )[1],
  },
  files = {
    runtime_scripts = vim.api.nvim_get_runtime_file("scripts/*", true),
    runtime_fonts = vim.api.nvim_get_runtime_file("font/*", true),
  },
}
standard_opts.font = {
  faces = {
    {
      name = "MonoLisa Trial Regular Nerd Font Complete Windows Compatible",
      src = [[url(']] ..
          standard_opts.dirs.font ..
          [[/MonoLisa Trial Regular Nerd Font Complete Windows Compatible.ttf') format("truetype")]]
    },
    {
      name = "MonoLisa Trial Regular Italic Nerd Font Complete Windows Compatible",
      src = [[url(']] ..
          standard_opts.dirs.font ..
          [[/MonoLisa Trial Regular Italic Nerd Font Complete Windows Compatible.ttf') format("truetype")]]
    },
  },
  size = 11,
}
standard_opts.files.render_script = standard_opts.dirs.scripts .. "/" .. shortname .. ".spec.ts"
standard_opts.files.render_css = standard_opts.dirs.css .. "/" .. shortname .. ".css"

local function new_output_files()
  local cur_name = vim.fn.expand("%:t")
  if cur_name == nil or cur_name == "" then
    cur_name = "noname"
  end
  local normalized_name = vim.fn.substitute(cur_name, "\\W", "", "g")
  local temp = vim.fn.tempname()
  local temp_prefix = vim.fn.fnamemodify(temp, ":h:t")
  local temp_name = vim.fn.fnamemodify(temp, ":t")
  local out_file = M.opts.dirs.output .. "/" .. temp_prefix .. "-" .. temp_name .. "-" .. normalized_name
  return {
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

  if M.opts.features.flash then
    M.opts.fn.flash()
  end

  local screenshot
  local retries = 10
  repeat
    vim.cmd.sleep("200ms")
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
  vim.fn.jobstart(M.opts.fn.aha.cmd(out_files), M.opts.fn.aha.opts(out_files))
end

M.opts = standard_opts

local function setup_files_and_dirs()
  renderfs.create_dirs(M.opts.dirs)

  local ok, err = pcall(renderfs.generateCSSFile, M.opts.font, M.opts.files.render_css)
  if not ok then
    render_notify(err, vim.log.levels.ERROR, {
      font = M.opts.font,
      render_style = M.opts.files.render_css,
    })
  end


  local init_files = {}
  init_files[M.opts.files.runtime_fonts] = M.opts.dirs.font
  init_files[M.opts.files.runtime_scripts] = M.opts.dirs.scripts
  ok, err = pcall(renderfs.createInitFiles, init_files)
  if not ok then
    render_notify(err, vim.log.levels.ERROR, {
      font = M.opts.font,
      render_style = M.opts.files.render_css,
    })
  end
end

local function setup_user_commands()
  vim.api.nvim_create_user_command("Render", function()
    -- small delay to avoid capturing :Render command and flash
    vim.defer_fn(M.render, 200)
  end, {})
  vim.api.nvim_create_user_command("RenderClean", function()
    renderfs.remove_dirs(M.opts.dirs)
    setup_files_and_dirs()
  end, {})
  vim.api.nvim_create_user_command("RenderQuickfix", function()
    vim.cmd.vimgrep(
      {
        args = { "/\\%^/j " .. M.opts.dirs.output .. "/*" },
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
end

M.setup = function(override_opts)
  if override_opts == nil then
    override_opts = {}
  end
  M.opts = vim.tbl_deep_extend("force", M.opts, override_opts)

  setup_files_and_dirs()
  setup_user_commands()

  if M.opts.features.keymaps then
    M.opts.fn.keymap_setup()
  end
end

return M
