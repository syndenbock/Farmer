local addonName, addon = ...;

if (addon.isClassic()) then return end

local MESSAGE_COLORS = {0.9, 0.3, 0};

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

local function checkProfessionOptions ()
  return (saved.farmerOptions.skills == true);
end

local function displayProfession (name, icon, rank, maxRank)
  local text = addon.stringJoin({'(', rank, '/', maxRank, ')'}, '');

  icon = addon.getIcon(icon);

  addon.Print.printMessage(addon.stringJoin({icon, name, text}, ' '),
      MESSAGE_COLORS);
end

addon.listen('PROFESSION_CHANGED', function (_, _, name, icon, rank, maxRank)
  if (not checkProfessionOptions()) then return end

  displayProfession(name, icon, rank, maxRank);
end);
