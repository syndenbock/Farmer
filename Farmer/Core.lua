local addonName, addon = ...

local L = addon.L

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
      error('Farmer: addon key already in use: ' .. key)
    end
    proxy[key] = value
  end

  function proxy:__index (key)
    if (proxy[key] == nil) then
      error('Farmer: addon key does not exist: ' .. key)
    end

    return proxy[key]
  end

  setmetatable(addon, proxy)
end

addon.vars = {}

--[[
///#############################################################################
/// event handling
///#############################################################################
--]]
do
  local events = {}
  local addonFrame = CreateFrame('frame')

  function addon:on (event, callback)
    if (events[event] == nil) then
      events[event] = {}
      addonFrame:RegisterEvent(event)
    end
    events[event][#events[event] + 1] = callback
  end

  local function eventHandler (self, event, ...)
    for i = 1, #events[event] do
      events[event][i](...)
    end
  end

  addon:on('ADDON_LOADED', function (name)
    if (name == addonName) then
      options = options or {}
      charOptions = charOptions or {}
    end
  end)

  addonFrame:SetScript('OnEvent', eventHandler)
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
      error('Farmer: slash handler already exists for ' .. command)
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
    print('Farmer: ' .. L['unknown command'] .. ' "' .. input .. '"')
  end

  SLASH_FARMER1 = '/farmer'
  SlashCmdList.FARMER = slashHandler
end

--[[
///#############################################################################
/// utility
///#############################################################################
--]]

function addon:stringJoin (stringList, joiner)
  joiner = joiner or '';
  local result = nil;

  for index, fragment in pairs(stringList) do
    if (fragment ~= nil) then
      if (result == nil) then
        result = fragment;
      else
        result = result .. joiner .. fragment;
      end
    end
  end

  return result or '';
end

function addon:getIcon (texture)
  return addon:stringJoin({'|T', texture, addon.vars.iconOffset, '|t'}, '');
end

function addon:printTable (table)
  for i,v in pairs(table) do
    print(i, ' - ', v)
  end
end
