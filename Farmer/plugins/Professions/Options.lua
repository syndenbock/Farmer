local addonName, addon = ...;

if (addon.isClassic()) then return end

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Professions'], addon.mainPanel);
local professionBox = panel:addCheckBox(L['show profession levelups']);

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    professions = true,
  },
}).vars;

panel:OnLoad(function ()
  professionBox:SetValue(saved.farmerOptions.professions);
end);

panel:OnSave(function ()
  saved.farmerOptions.professions = professionBox:GetValue();
end);
