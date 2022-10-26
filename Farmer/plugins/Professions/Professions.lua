local addonName, addon = ...;

if (not addon.isDetectorAvailable('professions')) then return end

local printMessageWithData = addon.Print.printMessageWithData;

local farmerFrame = addon.frame;

local MESSAGE_COLORS = {r = 0.9, g = 0.3, b = 0};
local SUBSPACE = farmerFrame:CreateSubspace();

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Professions;

local function checkProfessionOptions (info)
  return (options.displayProfessions == true and info.parentProfessionID);
end

local function displayProfession (info, change)
  local text = addon.stringJoin({'(', info.skillLevel, '/', info.maxSkillLevel, ')'}, '');
  local changeText;

  change = change + (farmerFrame:GetMessageData(SUBSPACE, info.professionID) or 0);

  if (change >= 0) then
    changeText = '+' .. change;
  else
    changeText = change;
  end

  text = addon.stringJoin({info.professionName, changeText, text}, ' ');
  printMessageWithData(SUBSPACE, info.professionID, change, text, MESSAGE_COLORS);
end

addon.listen('PROFESSION_CHANGED', function (info, change)
  if (not checkProfessionOptions(info)) then return end

  displayProfession(info, change);
end);
