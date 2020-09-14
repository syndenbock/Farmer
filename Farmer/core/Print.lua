local addonName, addon = ...;

local unpack = _G.unpack;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local IsActiveBattlefieldArena = _G.IsActiveBattlefieldArena;

local farmerFrame = addon.frame;
local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {},
}).vars.farmerOptions.Core;

local Print = {};
local mailIsOpen = false;

addon.Print = Print;

addon.on('MAIL_SHOW', function ()
  mailIsOpen = true;
end);

--[[ when having the mail open and accepting a queue, the MAIL_CLOSED event does
not fire, so we clear the flag after entering the world --]]
addon.on({'MAIL_CLOSED', 'PLAYER_ENTERING_WORLD'}, function ()
  mailIsOpen = false;
end);

function Print.checkHideOptions ()
  if (options.hideAtMailbox == true and
      mailIsOpen) then
    return false;
  end

  if (options.hideOnExpeditions == true and
      -- cannot be deferred earlier, as this frame gets initialized dynamically
      _G.IslandsPartyPoseFrame and
      _G.IslandsPartyPoseFrame:IsShown()) then
    return false;
  end

  if (options.hideInArena == true and
      IsActiveBattlefieldArena and
      IsActiveBattlefieldArena()) then
    return false;
  end

  return true;
end

function Print.printMessage (message, colors)
  colors = colors or {1, 1, 1};

  farmerFrame:AddMessage(message, unpack(colors, 1, 3));
end

function Print.printItem (texture, name, count, text, colors, funcOptions)
  count = count or 1;
  funcOptions = funcOptions or {};

  local icon = addon.getIcon(texture);
  local itemName;
  local itemCount;
  local message;

  if (not funcOptions.minimumCount or count > funcOptions.minimumCount) then
    itemCount = 'x' .. BreakUpLargeNumbers(count);
  end

  if (options.itemNames == true or
      funcOptions.forceName == true) then
    itemName = name;
  end

  message = addon.stringJoin({itemName, itemCount, text}, ' ');

  if (message == '') then
    message = name;
  end

  Print.printMessage(icon .. ' ' .. message, colors);
end
