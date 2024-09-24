local addonName, addon = ...;

if (not addon.isDetectorAvailable('vignettes')) then return end

local strjoin = _G.strjoin;

local Yell = addon.import('core/logic/Yell');
local Utils = addon.import('core/utils/Utils');
local SavedVariables = addon.import('client/utils/SavedVariables');
local Print = addon.import('main/Print');

local truncate = Utils.truncate;

local options =
    SavedVariables.SavedVariablesHandler(addonName, 'farmerOptions').vars.farmerOptions.Minimap;

local function displayVignette (info, coords)
  local message = strjoin(' ',
    info.name,
    truncate(coords.x, 1) .. ',',
    truncate(coords.y, 1)
  );

  Print.printMessage(message);
end

local function shouldVignetteBeDisplayed (info)
  return (
    options.displayVignettes == true and
    info.onMinimap == true
  );
end

Yell.listen('NEW_VIGNETTE', function (info, coords)
  if (shouldVignetteBeDisplayed(info)) then
    displayVignette(info, coords);
  end
end);
