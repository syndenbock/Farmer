local addonName, addon = ...;

if (not addon.isDetectorAvailable('experience')) then return end

local L = addon.L;

local SavedVariables = addon.import('client/utils/SavedVariables');
local Panel = addon.import('client/classes/options/Panel');
local Options = addon.import('main/Options');

local panel = Panel:new(L['Experience'], Options.panel);

local options = SavedVariables.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Experience = {
      displayExperience = false,
      experienceThreshold = 1,
    },
  },
}).vars.farmerOptions.Experience;

panel:mapOptions(options, {
  displayExperience = panel:addCheckBox(L['show experience']),
  experienceThreshold = panel:addSlider(0, 100, L['minimum %'], '0', '100', 0),
});
