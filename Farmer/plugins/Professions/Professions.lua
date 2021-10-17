local addonName, addon = ...;

if (not addon.isDetectorAvailable('professions')) then return end

local printIconMessageWithData = addon.Print.printIconMessageWithData;

local farmerFrame = addon.frame;

local MESSAGE_COLORS = {0.9, 0.3, 0};
local SUBSPACE = farmerFrame:CreateSubspace();

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Professions;

local function checkProfessionOptions ()
  return (options.displayProfessions == true);
end

local function displayProfession (info, change)
  local text = addon.stringJoin({'(', info.rank, '/', info.maxRank, ')'}, '');
  local changeText;

  change = change + (farmerFrame:GetMessageData(SUBSPACE, info.id) or 0);

  if (change >= 0) then
    changeText = '+' .. change;
  else
    changeText = change;
  end

  text = addon.stringJoin({info.name, changeText, text}, ' ');
  printIconMessageWithData(SUBSPACE, info.id, change, info.icon, text, MESSAGE_COLORS);
end

addon.listen('PROFESSION_CHANGED', function (info, change)
  if (not checkProfessionOptions()) then return end

  displayProfession(info, change);
end);
