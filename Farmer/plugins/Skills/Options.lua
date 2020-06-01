local addonName, addon = ...;

if (not addon:isClassic()) then return end

local L = addon.L;

local panel = addon.OptionFactory.Panel:New(L['Skills'], addon.mainPanel);
local professionBox = panel:addCheckBox(L['show skill levelups']);

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    skills = true,
  },
}).vars;

panel:OnLoad(function ()
  professionBox:SetValue(saved.farmerOptions.skills);
end);

panel:OnSave(function ()
  saved.farmerOptions.skills = professionBox:GetValue();
end);
