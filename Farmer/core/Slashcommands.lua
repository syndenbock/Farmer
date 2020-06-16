local addonName, addon = ...;

local L = addon.L;
local slashCommands = {};

function addon:slash (command, callback)
  assert(slashCommands[command] == nil,
      addonName .. ': slash handler already exists for ' .. command);

  slashCommands[command] = callback;
end

local function slashHandler (input)
  local paramList = {strsplit(' ', input)}
  local command = tremove(paramList, 1)

  command = string.lower(command or 'default');
  command = command == '' and 'default' or command;

  if (slashCommands[command]) then
    slashCommands[command](unpack(paramList));
    return;
  end

  print(addonName .. ': ' .. L['unknown command'] .. ' "' .. input .. '"');
end

_G['SLASH_' .. addonName .. '1'] = '/' .. addonName;
SlashCmdList[addonName] = slashHandler;
