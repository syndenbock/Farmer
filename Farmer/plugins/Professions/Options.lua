local addonName, addon = ...;

if (addon.isClassic()) then return end

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Professions'], addon.mainPanel);

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    professions = true,
  },
}).vars.farmerOptions;

panel:mapOptions(options, {
  professions = panel:addCheckBox(L['show profession levelups']),
});
