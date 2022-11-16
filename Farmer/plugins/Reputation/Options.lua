local addonName, addon = ...;

if (not addon.isDetectorAvailable('reputation')) then return end

local L = addon.L;

local panel = addon.import('Class/Options/Panel'):new(L['Reputation'], addon.mainPanel);

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Reputation = {
      displayReputation = true,
      reputationThreshold = 15,
    },
  },
}).vars.farmerOptions.Reputation;

panel:mapOptions(options, {
  displayReputation = panel:addCheckBox(L['show reputation']),
  reputationThreshold = panel:addSlider(1, 100, L['minimum'], '1', '100', 0),
});
