local addonName, addon = ...;

local EventUtils = addon.import('Utils/Events');

local IsActiveBattlefieldArena = _G.IsActiveBattlefieldArena;

local MAIL_INTERACTION_TYPE = _G.Enum.PlayerInteractionType.MailInfo;

local DEFAULT_COLOR = {r = 1, g = 1, b = 1, a = 1};

local farmerFrame = addon.frame;
local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars.farmerOptions.Core;

local mailIsOpen = false;

EventUtils.onInteractionFrameShow(MAIL_INTERACTION_TYPE, function ()
  mailIsOpen = true;
end);

EventUtils.onInteractionFrameHide(MAIL_INTERACTION_TYPE, function ()
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
  farmerFrame:AddMessage(message, colors or DEFAULT_COLOR);
end

local function printIconMessage (icon, message, colors)
  farmerFrame:AddIconMessage(icon, message, colors or DEFAULT_COLOR);
end

local function printAtlasMessage (atlas, message, colors)
  farmerFrame:AddAtlasMessage(atlas, message, colors or DEFAULT_COLOR);
end

local function printMessageWithData (subspace, identifier, data, message, colors)
  farmerFrame:AddMessageWithData(subspace, identifier, data, message, colors or DEFAULT_COLOR);
end

local function printIconMessageWithData (subspace, identifier, data, icon, message, colors)
  farmerFrame:AddIconMessageWithData(subspace, identifier, data, icon, message, colors or DEFAULT_COLOR);
end

local function printAtlasMessageWithData (subspace, identifier, data, atlas, message, colors)
  farmerFrame:AddAtlasMessageWithData(subspace, identifier, data, atlas, message, colors or DEFAULT_COLOR);
end

addon.Print = {
  checkHideOptions = checkHideOptions,
  printMessage = printMessage;
  printMessageWithData = printMessageWithData;
  printIconMessage = printIconMessage;
  printAtlasMessage = printAtlasMessage;
  printIconMessageWithData = printIconMessageWithData;
  printAtlasMessageWithData = printAtlasMessageWithData;
};
