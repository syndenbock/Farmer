local addonName, addon = ...;

local IsActiveBattlefieldArena = _G.IsActiveBattlefieldArena;

local DEFAULT_COLOR = {r = 1, g = 1, b = 1, a = 1};

local farmerFrame = addon.frame;
local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {},
}).vars.farmerOptions.Core;

local mailIsOpen = false;

local function onMailClosed ()
  mailIsOpen = false;
end

--[[ when having the mail open and accepting a queue, the MAIL_CLOSED event does
  not fire, so we clear the flag after entering the world --]]
addon.on('PLAYER_ENTERING_WORLD', onMailClosed);

do
  local mailType = addon.findGlobal('Enum', 'PlayerInteractionType', 'MailInfo');

  if (mailType ~= nil) then
    addon.on('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', function (_, type)
      if (type == mailType) then
        mailIsOpen = true;
      end
    end);

    addon.on('PLAYER_INTERACTION_MANAGER_FRAME_HIDE', function (_, type)
      if (type == mailType) then
        mailIsOpen = false;
      end
    end);
  else
    addon.on('MAIL_SHOW', function ()
      mailIsOpen = true;
    end);

    addon.on('MAIL_CLOSED', onMailClosed);
  end
end

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
  farmerFrame:AddMessage(message, colors or DEFAULT_COLOR);
end

local function printIconMessage (icon, message, colors)
  farmerFrame:AddIconMessage(icon, message, colors or DEFAULT_COLOR);
end

local function printMessageWithData (subspace, identifier, data, message, colors)
  farmerFrame:AddMessageWithData(subspace, identifier, data, message, colors or DEFAULT_COLOR);
end

local function printIconMessageWithData (subspace, identifier, data, icon, message, colors)
  farmerFrame:AddIconMessageWithData(subspace, identifier, data, icon, message, colors or DEFAULT_COLOR);
end

addon.Print = {
  checkHideOptions = checkHideOptions,
  printMessage = printMessage;
  printMessageWithData = printMessageWithData;
  printIconMessage = printIconMessage;
  printIconMessageWithData = printIconMessageWithData;
};
