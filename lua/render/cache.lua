---@mod render.cache Render Cache

---@class RenderCacheCountdownTimer
---@field count integer The value of the countdown timer

---@class RenderCache
---@field job_ids table<integer, RenderCacheJob> key is screencapture job id, value is job information
---@field timers table<integer, RenderCacheCountdownTimer> key is buffer handle, value is value of countdown timer
---@field window RenderWindowInfo window information for current neovim instance
local M = {
  ---@class RenderCacheJob
  ---@field window_info RenderWindowInfo job window information
  ---@field out_files RenderOutputFiles job output files
  ---@field timer table luv timer object for video job
  job_ids = {},
  timers = {},
  window = {},
}

return M
