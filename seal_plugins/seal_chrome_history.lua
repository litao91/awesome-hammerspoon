local obj = {}
obj.__index = obj

obj.__name = "seal_chrome_history"

function obj:commands()
  return {chis= {
      cmd = "chis",
      fn = obj.runChromeHistory,
      name = "Chrome History",
      description = "Search Chrome History",
      plugin = obj.__name
    }
  }
end

function obj:bare()
  return nil
end

function obj.runChromeHistory(query)
  if query == nil or query == "" or query == ".*" or string.len(query) < 3  then
    return
  end
  local script = os.getenv("HOME") .. "/.hammerspoon/seal_plugins/query_chrome_history"
  local cmd = script .. " \"" .. query .. "\""
  local r = hs.execute(cmd)
  print(r)
  local decoded_data = hs.json.decode(r)
  return decoded_data
end

function obj.completionCallback(rowInfo)
    hs.urlevent.openURLWithBundle(rowInfo["arg"], "com.google.Chrome")
end

return obj
