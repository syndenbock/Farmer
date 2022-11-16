local addonName, addon = ...;

if (not addon.isDetectorAvailable('currencies')) then return end

local L = addon.L;

local panel = addon.import('Class/Options/Panel'):new(L['Currencies'], addon.mainPanel);

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Currency = {
      displayCurrencies = true,
      ignoreHonor = true,
    },
  },
}).vars.farmerOptions.Currency;

panel:mapOptions(options, {
  displayCurrencies = panel:addCheckBox(L['show currencies']),
  ignoreHonor = panel:addCheckBox(L['ignore Honor']),
});
