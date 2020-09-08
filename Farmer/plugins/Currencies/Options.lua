local addonName, addon = ...;

if (addon.isClassic()) then return end

local L = addon.L;

local panel = addon.OptionClass.Panel:new(L['Currencies'], addon.mainPanel);

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
