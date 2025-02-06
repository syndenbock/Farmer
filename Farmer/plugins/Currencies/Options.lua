local addonName, addon = ...;

if (not addon.isDetectorAvailable('currencies')) then return end

local L = addon.L;

local SavedVariables = addon.import('client/utils/SavedVariables');
local Panel = addon.import('client/classes/options/Panel');
local Options = addon.import('main/Options');

local panel = Panel:new(L['Currencies'], Options.panel);

local options = SavedVariables.SavedVariablesHandler(addonName, 'farmerOptions', {
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
