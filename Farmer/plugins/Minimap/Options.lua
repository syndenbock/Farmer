local addonName, addon = ...;

if (not addon.isDetectorAvailable('vignettes')) then return end

local L = addon.L;
local SavedVariables = addon.import('client/utils/SavedVariables');
local Panel = addon.import('client/classes/options/Panel');
local Options = addon.import('main/Options');

local panel = Panel:new(L['Minimap'], Options.panel);

local options = SavedVariables.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Minimap = {
      displayVignettes = false,
    },
  },
}).vars.farmerOptions.Minimap;

panel:mapOptions(options, {
  displayVignettes = panel:addCheckBox(L['display vignettes that appear on the minimap']),
});
