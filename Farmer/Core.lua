local addonName, addon = ...

local L = addon.L

addon.vars = {}

--[[
///#############################################################################
/// proxy
///#############################################################################
--]]
do
  local proxy = {}

  function proxy:__index (key)
    return proxy[key]
  end

  function proxy:__newindex (key, value)
    if (proxy[key] ~= nil) then
      error(addonName .. ': addon key already in use: ' .. key)
    end
    proxy[key] = value
  end

  function proxy:__index (key)
    if (proxy[key] == nil) then
      error(addonName .. ': addon key does not exist: ' .. key)
    end

    return proxy[key]
  end

  setmetatable(addon, proxy)
end

--[[
///#############################################################################
/// event handling
///#############################################################################
--]]
do
  local events = {}
  local addonFrame = CreateFrame('frame')

  function addon:on (event, callback)
    local list = events[event];

    if (list == nil) then
      events[event] = {callback}
      addonFrame:RegisterEvent(event)
    else

      list[#list + 1] = callback;
    end
  end

  local function eventHandler (self, event, ...)
    for i = 1, #events[event] do
      events[event][i](...)
    end
  end

  addonFrame:SetScript('OnEvent', eventHandler)
end

--[[
//##############################################################################
// event funneling
//##############################################################################
--]]
function addon:funnel (eventList, ...)
  local arguments = {...};
  local flag = false;
  local timeSpan;
  local callback;

  if (#arguments >= 2) then
    timeSpan = arguments[1];
    callback = arguments[2];
  else
    timeSpan = 0;
    callback = arguments[1];
  end

  local funnel = function (...)
    local args = {...};

    if (flag == false) then
      flag = true;

      C_Timer.After(timeSpan, function ()
        flag = false;
        callback(unpack(args));
      end);
    end
  end

  addon:on(eventList, funnel);

  -- returning funnel for manual call
  return funnel;
end

--[[
///#############################################################################
/// slash command handling
///#############################################################################
--]]
do
  local slashCommands = {}

  function addon:slash (command, callback)
    if (slashCommands[command] ~= nil) then
      error(addonName .. ': slash handler already exists for ' .. command)
      return
    end

    slashCommands[command] = callback
  end

  local function slashHandler (input)
    local split = {string.split(' ', input)}
    local command = split[1]
    local paramList = {unpack(split, 2)}

    command = string.lower(command or 'default')
    command = command == '' and 'default' or command

    if (slashCommands[command] ~= nil) then
      slashCommands[command](unpack(paramList))
      return
    end
    print(addonName .. ': ' .. L['unknown command'] .. ' "' .. input .. '"')
  end

  SLASH_FARMER1 = '/' .. addonName
  SlashCmdList.FARMER = slashHandler
end
