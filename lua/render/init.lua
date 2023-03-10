local render_dir = "render"


-- TODO: look into getfontname([{name}])		String	name of font being used
local M = {}

local renderdata = vim.fn.stdpath("data") .. "/" .. render_dir
local renderstate = vim.fn.stdpath("state") .. "/" .. render_dir
local renderrun = vim.fn.stdpath("run") .. "/" .. render_dir
vim.fn.mkdir(renderdata, "p")

M.render = function()
  local outpath = vim.fn.tempname()
  local catfile = outpath .. ".cat"
  local htmlfile = outpath .. ".html"
  local pngfile = outpath .. ".png"

  -- WARNING undocumented nvim function this may have breaking changes in the future
  vim.api.nvim__screenshot(catfile)


  local screenshot
  local retries = 6
  repeat
    vim.cmd.sleep("500ms")
    -- wait until screenshot has succesfully written to file
    local ok, file_content = pcall(vim.fn.readfile, catfile)
    if ok and file_content ~= nil and file_content ~= "" then
      screenshot = file_content
      break
    end
  until retries == 0

  if screenshot == nil or next(screenshot) == nil then
    vim.notify("render.nvim error reading cat file", vim.log.levels.ERROR, {})
    return
  end

  -- parse and remove dimensions of the screenshot
  local first_line = screenshot[1]
  local dimensions = vim.fn.split(first_line, ",")
  local height = dimensions[1]
  local width = dimensions[2]
  if height ~= nil and height ~= "" and width ~= nil and width ~= "" then
    table.remove(screenshot, 1)
    vim.notify("height: " .. height .. " width: " .. width, vim.log.levels.DEBUG, {})
  end
  vim.fn.writefile(screenshot, catfile)

  -- render html
  local font = vim.api.nvim_get_runtime_file("resources/render/font.css", false)[1] -- TODO: validation
  vim.fn.jobstart({
    "aha",
    '--css',
    font,
    '-f',
    catfile,
  }, {
    stdout_buffered = true,
    on_stdout = function(_, aha_result)
      vim.fn.writefile(aha_result, htmlfile)

      -- render png
      local rasterize = vim.api.nvim_get_runtime_file("resources/render/rasterize.js", false)[1] -- TODO: validation
      vim.fn.jobstart({
        "phantomjs",
        rasterize,
        htmlfile,
        pngfile,
      }, {
        on_exit = function(_, exit_code)
          if exit_code == 0 then
            -- vim.fn.system("open " .. htmlfile)
            vim.fn.jobstart("open " .. pngfile)
          else
            vim.notify("render.nvim: failed to execute phantomjs", vim.log.levels.WARN, {})
          end
        end
      })
    end
  })
end

M.setup = function()
  local r = require("render")
  vim.api.nvim_create_user_command("Render", r.render, {})
  vim.keymap.set({ 'n', 'v', 'o' }, '<leader><leader><leader>', function()
    r.render()
  end, {
    silent = true
  })
end

return M
