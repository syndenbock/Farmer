local addonName, addon = ...;

if (addon.isClassic()) then return end

local L = addon.L;

local panel = addon.OptionClass.Panel:new(L['Minimap'], addon.mainPanel);

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Minimap = {
      displayVignettes = false,
    },
  },
}).vars.farmerOptions.Minimap;

panel:mapOptions(options, {
  displayVignettes = panel:addCheckBox(L['display vignettes that appear on the minimap']),
});
