local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionFactory.Panel:New(L['Autoloot'], addon.mainPanel);
local fastLootBox = panel:addCheckBox(L['enable fast autoloot']);

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    fastLoot = true,
  },
}).vars;

panel:OnLoad(function ()
  fastLootBox:SetValue(saved.farmerOptions.fastLoot);
end);

panel:OnSave(function ()
  saved.farmerOptions.fastLoot = fastLootBox:GetValue();
end);
