local Job = require("plenary.job")

---@class Glypho
---@field cmd string "Path to glypho binary"
---@field file string "Path to file to preview"
---@field port number "Port to open glypho"
---@field job Job "Pid of glypho process"

local Glypho = {
  cmd = "glypho",
  file = " ",
  port = 3030,
  job = nil,
}

function Glypho:start()
  local cwd = vim.fn.getcwd()
  self.file = cwd .. "/" .. vim.fn.expand("%")

  vim.print(self.file)
  local job = Job:new({
    command = self.cmd,
    args = { self.file },
    cwd = cwd,
    detached = true,
    on_stdout = function(_, data)
      vim.notify("daemon: " .. data, vim.log.levels.INFO)
    end,

    on_stderr = function(_, data)
      vim.print("daemon ERROR: " .. data)
      vim.notify("daemon ERROR: " .. data, vim.log.levels.ERROR)
    end,

    on_exit = function(_, code)
      vim.print("daemon exited with code " .. code)
      vim.notify("daemon exited with code " .. code, vim.log.levels.WARN)
    end,
  })
  self.job = job
  self.job:start()
end

function Glypho:stop()
  self.job:shutdown()
end

return Glypho
