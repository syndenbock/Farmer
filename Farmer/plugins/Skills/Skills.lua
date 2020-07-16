local addonName, addon = ...;

if (not addon:isClassic()) then return end

local MESSAGE_COLORS = {0.9, 0.3, 0};

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

local function checkSkillOptions ()
  return (saved.farmerOptions.skills == true);
end

local function displaySkill (name, rank, maxRank)
  local text = addon:stringJoin({'(', rank, '/', maxRank, ')'}, '');

  addon.Print.printMessage(addon:stringJoin({name, text}, ' '), MESSAGE_COLORS);
end

addon:listen('SKILL_CHANGED', function (name, _, rank, maxRank)
  if (checkSkillOptions()) then
    displaySkill(name, rank, maxRank);
  end
end);
