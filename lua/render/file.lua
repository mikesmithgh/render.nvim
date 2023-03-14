local M = {}

M.copy = function(source, destination)
  local source_file = io.open(source, "rb")
  if source_file == nil then
    error("failed to open source file")
  end
  local destination_file = io.open(destination, "wb")
  if destination_file == nil then
    error("failed to open destination file")
  end

  local source_content = source_file:read("*all")
  destination_file:write(source_content)

  source_file:close()
  destination_file:close()
end

M.writeTable = function(source, destination)
  local destination_file = io.open(destination, "w")
  if destination_file == nil then
    error("failed to open destination file")
  end

  for _, line in pairs(source) do
    destination_file:write(line .. "\n")
  end

  io.close(destination_file)
end

return M
