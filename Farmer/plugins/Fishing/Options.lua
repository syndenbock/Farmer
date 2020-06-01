local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionFactory.Panel:New(L['Fishing'], addon.mainPanel);
local healthBarBox = panel:addCheckBox(L['hide health bars while fishing']);
local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    hidePlatesWhenFishing = true,
  },
}).vars;

panel:OnLoad(function ()
  healthBarBox:SetValue(saved.farmerOptions.hidePlatesWhenFishing);
end);

panel:OnSave(function ()
  saved.farmerOptions.hidePlatesWhenFishing = healthBarBox:GetValue();
end);
