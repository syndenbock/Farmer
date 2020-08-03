local addonName, addon = ...;

if (addon.isClassic()) then return end

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Currencies'], addon.mainPanel);

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    currency = true,
    ignoreHonor = true,
  },
}).vars.farmerOptions;

panel:mapOptions(options, {
  currency = panel:addCheckBox(L['show currencies']),
  ignoreHonor = panel:addCheckBox(L['ignore Honor']),
});
