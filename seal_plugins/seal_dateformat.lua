local obj = {}
obj.__index = obj
obj.__name = "seal_dateformat"

function obj:commands()
  return {df = {
      cmd = "dateformat",
      fn = obj.runDateFormat,
      name = "Date Format",
      description = "Date conversion",
      plugin = obj.__name
    }
  }
end

function obj:bare()
  return nil
end

function obj.runDateFormat(query)
  if query == nil or query == "" or query == ".*" then
    return {}
  end
  local script = os.getenv("HOME") .. "/.hammerspoon/seal_plugins/process_dateformat.py"
  local cmd = "/usr/local/bin/python3 " .. script .. " \"" .. query .. "\""
  local r = hs.execute(cmd)
  local decoded_data = hs.json.decode(r)
  return decoded_data
end

function obj.completionCallback(rowInfo)
  hs.pasteboard.setContents(rowInfo["text"])
end

return obj
