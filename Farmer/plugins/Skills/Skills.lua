local addonName, addon = ...;

if (not addon.isDetectorAvailable('skills')) then return end

local strjoin = _G.strjoin;

local Yell = addon.import('core/logic/Yell');
local SavedVariables = addon.import('client/utils/SavedVariables');
local Main = addon.import('main/Main');
local Print = addon.import('main/Print');

local printMessageWithData = Print.printMessageWithData;

local SUBSPACE = Main.frame:CreateSubspace();
local MESSAGE_COLORS = {r = 0.9, g = 0.3, b = 0};

local options =
    SavedVariables.SavedVariablesHandler(addonName, 'farmerOptions').vars.farmerOptions.Skills;

local function checkSkillOptions ()
  return (options.displaySkills == true);
end

local function displaySkill (info)
  local text = strjoin('', '(', info.rank, '/', info.maxRank, ')');
  local changeText;

  local change = info.rankChange + (Main.frame:GetMessageData(SUBSPACE, info.name) or 0);

  if (change >= 0) then
    changeText = '+' .. change;
  else
    changeText = change;
  end

  text = strjoin(' ', info.name, changeText, text);
  printMessageWithData(SUBSPACE, info.name, change, text, MESSAGE_COLORS);
end

Yell.listen('SKILL_CHANGED', function (info)
  if (checkSkillOptions()) then
    displaySkill(info);
  end
end);
