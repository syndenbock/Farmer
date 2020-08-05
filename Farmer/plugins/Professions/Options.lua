local addonName, addon = ...;

if (addon.isClassic()) then return end

local L = addon.L;

local panel = addon.OptionClass.Panel:new(L['Professions'], addon.mainPanel);

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
