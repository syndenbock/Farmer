local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Misc'], addon.mainPanel);
local fastLootBox = panel:addCheckBox(L['enable fast autoloot']);
local healthBarBox = panel:addCheckBox(L['hide health bars while fishing']);

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    fastLoot = true,
    hidePlatesWhenFishing = true,
  },
}).vars;

panel:OnLoad(function ()
  fastLootBox:SetValue(saved.farmerOptions.fastLoot);
  healthBarBox:SetValue(saved.farmerOptions.hidePlatesWhenFishing);
end);

panel:OnSave(function ()
  saved.farmerOptions.fastLoot = fastLootBox:GetValue();
  saved.farmerOptions.hidePlatesWhenFishing = healthBarBox:GetValue();
end);
