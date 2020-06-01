local addonName, addon = ...;

if (addon:isClassic()) then return end

local MESSAGE_COLORS = {0.9, 0.3, 0};

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

addon:listen('PROFESSION_CHANGED', function (id, change, name, icon, rank, maxRank)
  if (saved.farmerOptions.skills ~= true) then return end

  local text = addon:stringJoin({'(', rank, '/', maxRank, ')'}, '');

  icon = addon:getIcon(icon);

  addon.Print.printMessage(addon:stringJoin({icon, name, text}, ' '), MESSAGE_COLORS);
end);
