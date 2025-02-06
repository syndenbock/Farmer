local addonName, addon = ...;

if (not addon.isDetectorAvailable('reputation')) then return end

local L = addon.L;
local SavedVariables = addon.import('client/utils/SavedVariables');
local Panel = addon.import('client/classes/options/Panel');
local Options = addon.import('main/Options');

local panel = Panel:new(L['Reputation'], Options.panel);

local options = SavedVariables.SavedVariablesHandler(addonName, 'farmerOptions', {
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
