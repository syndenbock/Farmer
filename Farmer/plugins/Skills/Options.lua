local addonName, addon = ...;

if (not addon.isClassic()) then return end

local L = addon.L;

local panel = addon.OptionClass.Panel:new(L['Skills'], addon.mainPanel);

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    skills = true,
  },
}).vars.farmerOptions;

panel:mapOptions(options, {
  skills = panel:addCheckBox(L['show skill levelups']),
});
