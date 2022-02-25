local addonName, addon = ...;

local unpack = _G.unpack;
local IsActiveBattlefieldArena = _G.IsActiveBattlefieldArena;

local DEFAULT_COLOR = {1, 1, 1, 1};

local farmerFrame = addon.frame;
local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {},
}).vars.farmerOptions.Core;

local mailIsOpen = false;

addon.on('MAIL_SHOW', function ()
  mailIsOpen = true;
end);

--[[ when having the mail open and accepting a queue, the MAIL_CLOSED event does
not fire, so we clear the flag after entering the world --]]
addon.on({'MAIL_CLOSED', 'PLAYER_ENTERING_WORLD'}, function ()
  mailIsOpen = false;
end);

local function checkHideOptions ()
  if (options.hideAtMailbox == true and
      mailIsOpen) then
    return false;
  end

  if (options.hideInArena == true and
      IsActiveBattlefieldArena and
      IsActiveBattlefieldArena()) then
    return false;
  end

  return true;
end

local function printMessage (message, colors)
  farmerFrame:AddMessage(message, unpack(colors or DEFAULT_COLOR));
end

local function printIconMessage (icon, message, colors)
  farmerFrame:AddIconMessage(icon, message, unpack(colors or DEFAULT_COLOR));
end

local function printMessageWithData (subspace, identifier, data, message, colors)
  farmerFrame:AddMessageWithData(subspace, identifier, data, message, unpack(colors or DEFAULT_COLOR));
end

local function printIconMessageWithData (subspace, identifier, data, icon, message, colors)
  farmerFrame:AddIconMessageWithData(subspace, identifier, data, icon, message, unpack(colors or DEFAULT_COLOR));
end

addon.Print = {
  checkHideOptions = checkHideOptions,
  printMessage = printMessage;
  printMessageWithData = printMessageWithData;
  printIconMessage = printIconMessage;
  printIconMessageWithData = printIconMessageWithData;
};
