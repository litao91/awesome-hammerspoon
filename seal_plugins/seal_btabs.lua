local obj = {}

obj.__index = obj
obj.__name = "seal_btabs"


function obj:bare()
  return nil
end

function obj:commands()
  return {
    btabs = {
      cmd = "btabs",
      fn = obj.browserTabsRequest,
      name = "Chrome Tabs",
      description = "Search the opening tabs of chrome",
      plugin = obj.__name,
    }
  }
end


function obj.browserTabsRequest(query)
   if query == nil or query == "" then
      return {}
   end
    local chooser_data = {}
    local chrome_running = hs.application.applicationsForBundleID("com.google.Chrome")
    if #chrome_running > 0 then
        local stat, data= hs.osascript.applescript([[tell application "Google Chrome"
set winlist to tabs of windows
set tablist to {}
repeat with i in winlist
if (count of i) > 0 then
repeat with currenttab in i
set tabinfo to {name of currenttab as unicode text, URL of currenttab}
copy tabinfo to the end of tablist
end repeat
end if
end repeat
return tablist
end tell]])
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

function chrome_active_tab_with_name(name)
    return function()
        hs.osascript.javascript([[
            // below is javascript code
            var chrome = Application('Google Chrome');
            chrome.activate();
            var wins = chrome.windows;

            // loop tabs to find a web page with a title of <name>
            function main() {
                for (var i = 0; i < wins.length; i++) {
                    var win = wins.at(i);
                    var tabs = win.tabs;
                    for (var j = 0; j < tabs.length; j++) {
                    var tab = tabs.at(j);
                    tab.title(); j;
                    if (tab.title().indexOf(']] .. name .. [[') > -1) {
                            win.activeTabIndex = j + 1;
                            return;
                        }
                    }
                }
            }
            main();
            // end of javascript
        ]])
    end
end

function chrome_active_tab_with_url(url)
    return function()
        hs.osascript.javascript([[
            // below is javascript code
            var chrome = Application('Google Chrome');
            chrome.activate();
            var wins = chrome.windows;

            // loop tabs to find a web page with a title of <name>
            function main() {
                for (var i = 0; i < wins.length; i++) {
                    var win = wins.at(i);
                    var tabs = win.tabs;
                    for (var j = 0; j < tabs.length; j++) {
                    var tab = tabs.at(j);
                    tab.title(); j;
                    if (tab.url().indexOf(']] .. url .. [[') > -1) {
                            win.activeTabIndex = j + 1;
                            return;
                        }
                    }
                }
            }
            main();
            // end of javascript
        ]])
    end
end

function obj.completionCallback(rowInfo)
  print(rowInfo["arg"])
  if rowInfo["type"] == "chrome" then
    -- chrome_active_tab_with_url(rowInfo["arg"])
    hs.urlevent.openURLWithBundle(rowInfo["arg"], "com.google.Chrome")
  end
end

return obj
