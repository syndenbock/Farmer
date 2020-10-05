local addonName, addon = ...;

if (addon.isClassic()) then return end

local truncate = addon.truncate;
local printMessage = addon.Print.printMessage;
local stringJoin = addon.stringJoin;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Minimap;

local function displayVignette (info, coords)
  local message = stringJoin({
    info.name,
    truncate(coords.x, 1) .. ',',
    truncate(coords.y, 1),
  }, ' ');

  printMessage(message);
end

addon.listen('NEW_VIGNETTE', function (info, coords)
  if (options.displayVignettes == true) then
    displayVignette(info, coords);
  end
end);
