local addonName, addon = ...;

if (not addon.isClassic()) then return end

local MESSAGE_COLORS = {0.9, 0.3, 0};

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Skills;

local function checkSkillOptions ()
  return (options.displaySkills == true);
end

local function displaySkill (info)
  local text = addon.stringJoin({'(', info.rank, '/', info.maxRank, ')'}, '');

  addon.Print.printMessage(addon.stringJoin({info.name, text}, ' '),
      MESSAGE_COLORS);
end

addon.listen('SKILL_CHANGED', function (info)
  if (checkSkillOptions()) then
    displaySkill(info);
  end
end);
