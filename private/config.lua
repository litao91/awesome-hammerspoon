-- Specify Spoons which will be loaded
hspoon_list = {
    --"AClock",
    -- "BingDaily",
    -- "Calendar",
    -- "CircleClock",
    "ClipShow",
    -- "CountDown",
    "FnMate",
    -- "HCalendar",
    -- "HSaria2",
    "HSearch",
    -- "KSheet",
    "SpeedMenu",
    -- "TimeFlow",
    -- "UnsplashZ",
    "WinWin",
    "KSheet",
}

-- appM environment keybindings. Bundle `id` is prefered, but application `name` will be ok.
hsapp_list = {
    -- {key = 'a', name = 'Atom'},
    {key = 'c', id = 'com.google.Chrome'},
    -- {key = 'd', name = 'ShadowsocksX'},
    --{key = 'e', name = 'Emacs'},
    {key = 'f', name = 'Finder'},
    {key = 'i', name = 'iTerm'},
  --  {key = 'k', name = 'KeyCastr'},
 --   {key = 'l', name = 'Sublime Text'},
    --{key = 'o', name = 'LibreOffice'},
    --{key = 'p', name = 'mpv'},
    -- {key = 'r', name = 'VimR'},
    --{key = 's', name = 'Safari'},
    --{key = 't', name = 'Terminal'},
    {key = 'n', name = 'Microsoft OneNote'},
    -- {key = 'v', id = 'com.apple.ActivityMonitor'},
    {key = 'v', name="Alacritty"},
    {key = 'l', id = "com.electron.lark"},
    {key = 'm', name = 'Mweb'},
    {key = 'y', id = 'com.apple.systempreferences'},
    {key = 'w', name = 'WeChat'},
    {key = 'j', name = 'Jump Desktop'},
    {key = 't', name = 'TaskPaper'},
    {key = 's', name = 'Querious'},
    {key = 'b', id = 'org.mozilla.firefox'},
}

-- Modal supervisor keybinding, which can be used to temporarily disable ALL modal environments.
hsupervisor_keys = {{"cmd", "shift", "ctrl"}, "Q"}

-- Reload Hammerspoon configuration
hsreload_keys = {{"cmd", "shift", "ctrl"}, "R"}

-- Toggle help panel of this configuration.
hshelp_keys = {{"alt", "shift"}, "/"}

-- aria2 RPC host address
hsaria2_host = "http://localhost:6800/jsonrpc"
-- aria2 RPC host secret
hsaria2_secret = "token"

----------------------------------------------------------------------------------------------------
-- Those keybindings below could be disabled by setting to {"", ""} or {{}, ""}

-- Window hints keybinding: Focuse to any window you want
hswhints_keys = {"alt", "tab"}

-- appM environment keybinding: Application Launcher
hsappM_keys = {"alt", "A"}

-- clipshowM environment keybinding: System clipboard reader
hsclipsM_keys = {"alt", "C"}

-- Toggle the display of aria2 frontend
hsaria2_keys = {"alt", "D"}

-- Launch Hammerspoon Search
hsearch_keys = {"alt", "G"}

-- Read Hammerspoon and Spoons API manual in default browser
hsman_keys = {"alt", "H"}

-- countdownM environment keybinding: Visual countdown
hscountdM_keys = {"alt", "I"}

-- Lock computer's screen
hslock_keys = {"alt", "L"}

-- resizeM environment keybinding: Windows manipulation
hsresizeM_keys = {"alt", "R"}

-- cheatsheetM environment keybinding: Cheatsheet copycat
hscheats_keys = {"alt", "S"}

-- Show digital clock above all windows
hsaclock_keys = {"alt", "T"}

-- Type the URL and title of the frontmost web page open in Google Chrome or Safari.
hstype_keys = {"alt", "X"}

-- Toggle Hammerspoon console
hsconsole_keys = {"alt", "Z"}

-- local modMoveWindow = {'shift', 'cmd'}
local modMoveFocus = {'shift', 'cmd'}
local modMovePosition = {'shift', 'option'}
local modMoveDisplay = {'shift', 'ctrl'}

-- local directionKey = {'up', 'down', 'left', 'right'}
local directionKey = {'h', 'j', 'k', 'l'}
local directionName = {'West', 'South', 'North', 'East'}
local positionName = {'halfleft', 'halfdown', 'halfup', 'halfright'}

local logger = hs.logger.new("private")

-- for k, v in pairs(directionKey) do
--   hs.hotkey.bind(modMoveWindow, v, function()
--       HS_H.focus:moveWindow({direction = v})
--     end)
-- end

function moveWindow(dir)
  local w = hs.window.frontmostWindow()
  local title = w:title()

  if #title > 23 then
    title = title:sub(0, 10) .. "..." .. title:sub(#title-9)
  end
  local fn = w["moveOneScreen" .. dir]
  fn(w)
  hs.alert("Moved '" .. title .. "' " .. dir, 2)
end

for k, v in pairs(directionKey) do
  hs.hotkey.bind(modMovePosition, v, function()
      spoon.WinWin:moveAndResize(positionName[k])
      hs.alert("Moved '" .. hs.window.frontmostWindow():title() .. "' to " .. positionName[k])
    end)
end

hs.hotkey.bind(modMovePosition, 'M', function()
      spoon.WinWin:moveAndResize('fullscreen')
      hs.alert("Moved '" .. hs.window.frontmostWindow():title() .. "' to fullscreen")
  end)

for k, v in pairs(directionKey) do
  hs.hotkey.bind(modMoveDisplay, v, function()
      moveWindow(directionName[k])
    end)
end

for k, v in pairs(directionKey) do 
  hs.hotkey.bind(modMoveFocus, v, function() 
    local fn = hs.window["focusWindow" .. directionName[k]]
    fn()
    local w = hs.window.frontmostWindow()
    hs.alert("Focused '" .. w:title() .. "'")
  end)
end

--[ fan ]-------------------------------------------------------------------
--[[
	my mac has a very noisy fan, this just puts the CPU temperature and fan
	speeds in the title bar
]]--

function os.capture(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  s = string.gsub(s, '^%s+', '')
  s = string.gsub(s, '%s+$', '')
  s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

local function updateStats()
  fanSpeed = os.capture("/usr/local/bin/istats fan speed --no-label --no-graph")
  temp = os.capture("/usr/local/bin/istats cpu temp --no-label --no-graph")
  batTemp = os.capture("/usr/local/bin/istats battery temp --no-label --no-graph")
  cpuRate = os.capture("ps -A -o %cpu | awk '{s+=$1} END {print s \"%\"}'")
  ramRate = os.capture("ps -A -o %mem | awk '{s+=$1} END {print s \"%\"}'")
end

local function makeStatsMenu(calledFromWhere)
  if statsMenu == nil then
    statsMenu = hs.menubar.new()
  end
  updateStats()
  statsMenu:setTitle(hs.styledtext.new("F: " .. fanSpeed .. " | T: " .. temp .. "\n BT: " .. batTemp .. "| CR: " .. cpuRate .. "| MR: " ..ramRate, {font={size=9.0, color={hex="#000000"}}} ))
end

updateStatsInterval = 20
statsMenuTimer = hs.timer.new(updateStatsInterval, makeStatsMenu)
statsMenuTimer:start()

updateStats()
makeStatsMenu()


local function Chinese()
  hs.keycodes.setMethod('Squirrel')
end

local function English()
  hs.keycodes.currentSourceID("com.apple.keylayout.US")
end

local function set_app_input_method(app_name, set_input_method_function, event)
  event = event or hs.window.filter.windowFocused

  hs.window.filter.new(app_name)
    :subscribe(event, function()
                 set_input_method_function()
              end)
end

set_app_input_method('Hammerspoon', English, hs.window.filter.windowCreated)
set_app_input_method('Spotlight', English, hs.window.filter.windowCreated)
set_app_input_method('iTerm2', English)
set_app_input_method('Alacritty', English)
set_app_input_method('Google Chrome', English)
set_app_input_method('WeChat', Chinese)
set_app_input_method('Lark', Chinese)
