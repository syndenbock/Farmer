local addonName, addon = ...;

local strlower = _G.strlower;
local strsplit = _G.strsplit;

local L = addon.L;
local slashCommands = {};

function addon.slash (command, callback)
  command = strlower(command);

  assert(slashCommands[command] == nil,
      addonName .. ': slash handler already exists for ' .. command);

  slashCommands[command] = callback;
end

local function executeSlashCommand (command, ...)
  local handler = slashCommands[strlower(command)];

  if (not handler) then
    return addon.printAddonMessage(L['unknown command'], '"' .. command .. '"');
  end

  handler(...);
end

local function slashHandler (input)
  if (input == nil or input == '') then
    return executeSlashCommand('default');
  end

  executeSlashCommand(strsplit(' ', input));
end

_G['SLASH_' .. addonName .. '1'] = '/' .. addonName;
_G.SlashCmdList[addonName] = slashHandler;
