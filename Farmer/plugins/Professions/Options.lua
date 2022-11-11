local addonName, addon = ...;

if (not addon.isDetectorAvailable('professions')) then return end

local L = addon.L;

local panel = addon.import('Class/Options/Panel'):new(L['Professions'], addon.mainPanel);

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Professions = {
      displayProfessions = true,
    },
  },
}).vars.farmerOptions.Professions;

panel:mapOptions(options, {
  displayProfessions = panel:addCheckBox(L['show profession levelups']),
});
