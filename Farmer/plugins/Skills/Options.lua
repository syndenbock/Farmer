local addonName, addon = ...;

if (not addon.isDetectorAvailable('skills')) then return end

local SavedVariables = addon.import('client/utils/SavedVariables');
local Panel = addon.import('client/classes/options/Panel');
local Options = addon.import('main/Options');
local L = addon.L;

local panel = Panel:new(L['Skills'], Options.mainPanel);

local options = SavedVariables.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Skills = {
      displaySkills = true,
    },
  },
}).vars.farmerOptions.Skills;

panel:mapOptions(options, {
  displaySkills = panel:addCheckBox(L['show skill levelups']),
});
