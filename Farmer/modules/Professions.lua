local addonName, addon = ...;

local MESSAGE_COLORS = {0.9, 0.3, 0};

addon:listen('PROFESSION_CHANGED', function (id, change, name, icon, rank, maxRank)
  local icon = addon:getIcon(icon);
  local text = addon:stringJoin({'(', rank, '/', maxRank, ')'}, '');

  addon.Print.printMessage(addon:stringJoin({icon, name, text}, ' '), MESSAGE_COLORS);
end);

