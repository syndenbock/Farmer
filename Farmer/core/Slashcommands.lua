local addonName, addon = ...;

local slashCommands = {};

function addon:slash (command, callback)
  if (slashCommands[command] ~= nil) then
    error(addonName .. ': slash handler already exists for ' .. command);
    return;
  end

  slashCommands[command] = callback;
end

local function slashHandler (input)
  local split = {string.split(' ', input)};
  local command = split[1];
  local paramList = {unpack(split, 2)};

  command = string.lower(command or 'default');
  command = command == '' and 'default' or command;

  if (slashCommands[command] ~= nil) then
    slashCommands[command](unpack(paramList));
    return;
  end

  print(addonName .. ': ' .. L['unknown command'] .. ' "' .. input .. '"');
end

_G['SLASH_' .. addonName .. '1'] = '/' .. addonName;
SlashCmdList[addonName] = slashHandler;
