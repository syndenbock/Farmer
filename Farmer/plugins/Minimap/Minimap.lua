local addonName, addon = ...;

if (not addon.isDetectorAvailable('vignettes')) then return end

local strjoin = _G.strjoin;
local truncate = addon.truncate;
local printMessage = addon.Print.printMessage;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Minimap;

local function displayVignette (info, coords)
  local message = strjoin(' ',
    info.name,
    truncate(coords.x, 1) .. ',',
    truncate(coords.y, 1)
  );

  printMessage(message);
end

local function shouldVignetteBeDisplayed (info)
  return (
    options.displayVignettes == true and
    info.onMinimap == true
  );
end

addon.listen('NEW_VIGNETTE', function (info, coords)
  if (shouldVignetteBeDisplayed(info)) then
    displayVignette(info, coords);
  end
end);
