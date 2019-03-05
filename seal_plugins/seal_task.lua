local obj = {}
obj.__index = obj
obj.__name = "seal_task"
obj.icon = hs.image.imageFromAppBundle("com.apple.Calculator")

function obj:commands()
  return {task = {
      cmd = "task",
      fn = obj.runTask,
      name = "Taskworrior",
      description = "Task worrior",
      plugin = obj.__name
    }
  }
end

function obj:bare()
  return nil
end

function obj.runTask(query)
  local choices = {}
  if query == nil or query == "" or query == ".*" then
    return choices
  end
  local script = os.getenv("HOME") .. "/.hammerspoon/seal_plugins/query_task.py"
  local cmd = "/usr/local/bin/python3 " .. script  .. " " .. query
  print(cmd)
  local r = hs.execute(cmd)
  local decoded_data = hs.json.decode(r)
  return decoded_data
end

function obj.completionCallback(rowInfo)
    if rowInfo["type"] == "cmd" then
      print(hs.execute(rowInfo['arg']))
    end
end

return obj
