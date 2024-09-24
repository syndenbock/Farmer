local addonName, addon = ...;

if (not addon.isDetectorAvailable('professions')) then return end

local L = addon.L;
local SavedVariables = addon.import('client/utils/SavedVariables');
local Panel = addon.import('client/classes/options/Panel');
local Options = addon.import('main/Options');

local panel = Panel:new(L['Professions'], Options.mainPanel);

local options = SavedVariables.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Professions = {
      displayProfessions = true,
    },
  },
}).vars.farmerOptions.Professions;

panel:mapOptions(options, {
  displayProfessions = panel:addCheckBox(L['show profession levelups']),
});
