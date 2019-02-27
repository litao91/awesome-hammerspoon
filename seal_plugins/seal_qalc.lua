local obj = {}
obj.__index = obj
obj.__name = "seal_qalc"
obj.icon = hs.image.imageFromAppBundle("com.apple.Calculator")

function obj:commands()
  return {qalc = {
      cmd = "qalc",
      fn = obj.runQalc,
      name = "Calculate",
      description = "Do calculation with qalc",
      plugin = obj.__name
    }
  }
end

function obj:bare()
  return nil
end

function trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function obj.runQalc(query)
  local choices = {}
  if query == nil or query == "" or query == ".*" then
    return choices
  end

  local choice = {}
  local cmd = "/usr/local/bin/qalc \"" .. query .. "\""
  print("CMD: " .. cmd)
  local result = hs.execute(cmd)
  choice["text"] = result
  choice["subText"] = "Copy result to clicpboard"
  choice["type"] = "copyToClipboard"
  table.insert(choices, choice)
  return choices
end

function obj.completionCallback(rowInfo)
    if rowInfo["type"] == "copyToClipboard" then
        hs.pasteboard.setContents(rowInfo["text"])
    end
end

return obj
