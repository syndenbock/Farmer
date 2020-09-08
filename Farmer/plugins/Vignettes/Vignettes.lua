local addonName, addon = ...;

if (addon.isClassic()) then return end

local truncate = addon.truncate;
local printMessage = addon.Print.printMessage;
local stringJoin = addon.stringJoin;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Minimap;

addon.listen('NEW_VIGNETTE', function (info, coords)
  if (options.displayVignettes == true) then
    printMessage(stringJoin({info.name, truncate(coords.x, 1), truncate(coords.y, 1)}, ' '));
  end
end);
