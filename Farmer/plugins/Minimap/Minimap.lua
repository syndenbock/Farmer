local addonName, addon = ...;

if (not addon.isDetectorAvailable('vignettes')) then return end

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

addon.listen('NEW_VIGNETTE', function (info, coords, onMinimap)
  if (options.displayVignettes == true and onMinimap == true) then
    displayVignette(info, coords);
  end
end);
