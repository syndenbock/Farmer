local addonName, addon = ...;

if (not addon.isDetectorAvailable('vignettes')) then return end

local strjoin = _G.strjoin;
local truncate = addon.truncate;
local printAtlasMessage = addon.Print.printAtlasMessage;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Minimap;

local function displayVignette (info, coords)
  local message = strjoin(' ',
    info.name,
    truncate(coords.x, 1) .. ',',
    truncate(coords.y, 1)
  );

  printAtlasMessage('VignetteKillElite', message);
end

local function shouldVignetteBeDisplayed (onMinimap)
  return (
    options.displayVignettes == true and
    onMinimap == true
  );
end

addon.listen('NEW_VIGNETTE', function (info, coords, onMinimap)
  if (shouldVignetteBeDisplayed(onMinimap)) then
    displayVignette(info, coords);
  end
end);
