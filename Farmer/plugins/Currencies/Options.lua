local addonName, addon = ...;

if (addon.isClassic()) then return end

local L = addon.L;

local panel = addon.OptionFactory.Panel:New(L['Currencies'], addon.mainPanel);
local enabledBox = panel:addCheckBox(L['show currencies']);
local ignoreHonorBox = panel:addCheckBox(L['ignore Honor']);
local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    currency = true,
    ignoreHonor = true,
  },
}).vars;

panel:OnLoad(function ()
  enabledBox:SetValue(saved.farmerOptions.currency);
  ignoreHonorBox:SetValue(saved.farmerOptions.ignoreHonor);
end);

panel:OnSave(function ()
  saved.farmerOptions.currency = enabledBox:GetValue();
  saved.farmerOptions.ignoreHonor = ignoreHonorBox:GetValue();
end);
