local addonName, addon = ...;

if (not addon.isDetectorAvailable('professions')) then return end

local strjoin = _G.strjoin;
local strconcat = _G.strconcat;

local Yell = addon.import('core/logic/Yell');
local SavedVariables = addon.import('client/utils/SavedVariables');
local Main = addon.import('main/Main');
local Print = addon.import('main/Print');

local printIconMessageWithData = Print.printIconMessageWithData;

local MESSAGE_COLORS = {r = 0.9, g = 0.3, b = 0};
local SUBSPACE = Main.frame:CreateSubspace();

local options =
    SavedVariables.SavedVariablesHandler(addonName, 'farmerOptions').vars.farmerOptions.Professions;

local function checkProfessionOptions (info)
  return (options.displayProfessions == true);
end

local function displayProfession (info, change)
  local text = strconcat('(', info.skillLevel, '/', info.maxSkillLevel, ')');
  local changeText;

  change = change + (Main.frame:GetMessageData(SUBSPACE, info.professionID) or 0);

  if (change >= 0) then
    changeText = '+' .. change;
  else
    changeText = change;
  end

  text = strjoin(' ', info.professionName, changeText, text);
  printIconMessageWithData(SUBSPACE, info.professionID, change, info.icon, text, MESSAGE_COLORS);
end

Yell.listen('PROFESSION_CHANGED', function (info, change)
  if (not checkProfessionOptions(info)) then return end

  displayProfession(info, change);
end);
