local obj = {}

obj.__index = obj
obj.__name = "seal_btabs"


function obj:bare()
  return self.browserTabsRequest
end

function obj:commands()
  return {}
end


function obj.browserTabsRequest(query)
   if query == nil or query == "" then
      return {}
   end
    local chooser_data = {}
    local chrome_running = hs.application.applicationsForBundleID("com.google.Chrome")
    if #chrome_running > 0 then
        local stat, data= hs.osascript.applescript('tell application "Google Chrome"\nset winlist to tabs of windows\nset tablist to {}\nrepeat with i in winlist\nif (count of i) > 0 then\nrepeat with currenttab in i\nset tabinfo to {name of currenttab as unicode text, URL of currenttab}\ncopy tabinfo to the end of tablist\nend repeat\nend if\nend repeat\nreturn tablist\nend tell')
        if stat then
            for idx,val in pairs(data) do
                if string.match(val[1]:lower(), query:lower()) then
                -- Usually we want to open chrome tabs in Google Chrome.
                  table.insert(chooser_data, {text=val[1],plugin=obj.__name, subText=val[2], image=hs.image.imageFromPath(obj.seal.spoonPath .. "/resources/chrome.png"), type="chrome", arg=val[2]})
                end
            end
        end
    end
    -- Return specific table as hs.chooser's data, other keys except for `text` could be optional.
    return chooser_data
end

function obj.completionCallback(rowInfo)
  if rowInfo["type"] == "chrome" then
    hs.urlevent.openURLWithBundle(rowInfo["arg"], "com.google.Chrome")
  end
end

return obj
