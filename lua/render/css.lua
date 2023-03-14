local M = {}

M.generateCSSTable = function(font)
  local css = {}

  local font_family = {}

  for _, face in pairs(font.faces) do
    table.insert(css, '@font-face {')
    table.insert(css, '    font-family: "' .. face.name .. '";')
    table.insert(css, '    src: ' .. face.src .. ';')
    table.insert(css, '}')
    table.insert(css, '')

    table.insert(font_family, '"' .. face.name .. '"')
  end

  table.insert(css, '* {')
  table.insert(css, '    font-family: ' .. table.concat(font_family, ", ") .. ';')
  table.insert(css, '    font-size: ' .. font.size .. 'px;')
  table.insert(css, '}')
  table.insert(css, '')

  table.insert(css, 'pre {')
  table.insert(css, '    position: absolute;')
  table.insert(css, '    /* avoid pre first line spacing */')
  table.insert(css, '    top: -1em;')
  table.insert(css, '    left: 0em;')
  table.insert(css, '}')

  return css
end

return M
