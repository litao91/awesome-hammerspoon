local obj = {}
obj.__index = obj
obj.__name = "seal_chrome_bookmarks"

function obj:commands()
  return {
    bm = {
      cmd = "bm",
      fn = obj.runQueryChromeBookmarks,
      name = "Chrome Bookmarks",
      description = "Search chrome bookmarks",
      plugin = obj.__name,

    }
  }
end

function obj:bare()
  return nil
end

function obj.runQueryChromeBookmarks(query)
  if query == nil or query == "" or query == ".*" then
    query = ""
  end
  local script = os.getenv("HOME") .. "/.hammerspoon/seal_plugins/query_chrome_bookmarks.py"
  local cmd = "/usr/local/bin/python3 " .. script .. " \"" .. query .. "\""
  local r = hs.execute(cmd)
  local decoded_data = hs.json.decode(r)
  return decoded_data
end

function obj.completionCallback(rowInfo)
  hs.urlevent.openURLWithBundle(rowInfo["arg"], "com.google.Chrome")
end

return obj

