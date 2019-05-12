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
    local command, param = input.split(' ', input, 3)

    command = command == '' and 'default' or command
    command = string.lower(command or 'default')
    param = string.lower(param or '')

    if (slashCommands[command] ~= nil) then
      slashCommands[command](param)
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
do
  function addon:printTable (table)
    for i,v in pairs(table) do
      print(i, ' - ', v)
    end
  end
end
