local addonName, addon = ...;

if (_G.TradeSkillUI == nil) then return end

local printMessageWithData = addon.Print.printMessageWithData;

local farmerFrame = addon.frame;

local MESSAGE_COLORS = {0.9, 0.3, 0};
local SUBSPACE = farmerFrame:CreateSubspace();

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Professions;

local function checkProfessionOptions ()
  return (options.displayProfessions == true);
end

local function displayProfession (info, change)
  local icon = addon.getIcon(info.icon);
  local text = addon.stringJoin({'(', info.rank, '/', info.maxRank, ')'}, '');
  local changeText;

  change = change + (farmerFrame:GetMessageData(SUBSPACE, info.id) or 0);

  if (change >= 0) then
    changeText = '+' .. change;
  else
    changeText = change;
  end

  text = addon.stringJoin({icon, info.name, changeText, text}, ' ');
  printMessageWithData(SUBSPACE, info.id, change, text, MESSAGE_COLORS);
end

addon.listen('PROFESSION_CHANGED', function (info, change)
  if (not checkProfessionOptions()) then return end

  displayProfession(info, change);
end);
