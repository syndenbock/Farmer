local addonName, addon = ...;

if (not addon.isDetectorAvailable('professions')) then return end

local strjoin = _G.strjoin;
local printIconMessageWithData = addon.Print.printIconMessageWithData;

local farmerFrame = addon.frame;

local MESSAGE_COLORS = {r = 0.9, g = 0.3, b = 0};
local SUBSPACE = farmerFrame:CreateSubspace();

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Professions;

local function checkProfessionOptions (info)
  return (options.displayProfessions == true);
end

local function displayProfession (info, change)
  local text = strjoin('', '(', info.skillLevel, '/', info.maxSkillLevel, ')');
  local changeText;

  change = change + (farmerFrame:GetMessageData(SUBSPACE, info.professionID) or 0);

  if (change >= 0) then
    changeText = '+' .. change;
  else
    changeText = change;
  end

  text = strjoin(' ', info.professionName, changeText, text);
  printIconMessageWithData(SUBSPACE, info.professionID, change, info.icon, text, MESSAGE_COLORS);
end

addon.listen('PROFESSION_CHANGED', function (info, change)
  if (not checkProfessionOptions(info)) then return end

  displayProfession(info, change);
end);
