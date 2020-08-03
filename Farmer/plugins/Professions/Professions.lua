local addonName, addon = ...;

if (addon.isClassic()) then return end

local MESSAGE_COLORS = {0.9, 0.3, 0};

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions;

local function checkProfessionOptions ()
  return (options.professions == true);
end

local function displayProfession (info)
  local text = addon.stringJoin({'(', info.rank, '/', info.maxRank, ')'}, '');
  local icon = addon.getIcon(info.icon);

  addon.Print.printMessage(addon.stringJoin({icon, info.name, text}, ' '),
      MESSAGE_COLORS);
end

addon.listen('PROFESSION_CHANGED', function (info)
  if (not checkProfessionOptions()) then return end

  displayProfession(info);
end);
