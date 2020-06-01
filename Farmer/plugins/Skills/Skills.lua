local addonName, addon = ...;

if (not addon:isClassic()) then return end

local MESSAGE_COLORS = {0.9, 0.3, 0};

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

addon:listen('SKILL_CHANGED', function (name, change, rank, maxRank)
  if (saved.farmerOptions.skills ~= true) then return end

  local text = addon:stringJoin({'(', rank, '/', maxRank, ')'}, '');

  addon.Print.printMessage(addon:stringJoin({name, text}, ' '), MESSAGE_COLORS);
end);
