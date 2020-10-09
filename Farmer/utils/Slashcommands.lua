local addonName, addon = ...;

local strsplit = _G.strsplit;
local tremove = _G.tremove;
local unpack = _G.unpack;

local L = addon.L;
local slashCommands = {};

function addon.slash (command, callback)
  assert(slashCommands[command] == nil,
      addonName .. ': slash handler already exists for ' .. command);

  slashCommands[command] = callback;
end

local function executeSlashCommand (command, ...)
  local handler = slashCommands[command];

  if (not handler) then
    return print(addonName .. ': ' .. L['unknown command'] .. ' "' .. command .. '"');
  end

  handler(...);
end

local function slashHandler (input)
  input = input or '';

  local paramList = {strsplit(' ', input)}
  local command = tremove(paramList, 1)

  command = string.lower(command or 'default');
  command = command == '' and 'default' or command;

  executeSlashCommand(command, unpack(paramList));
end

_G['SLASH_' .. addonName .. '1'] = '/' .. addonName;
_G.SlashCmdList[addonName] = slashHandler;
