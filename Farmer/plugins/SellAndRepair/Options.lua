local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Sell and Repair'], addon.mainPanel);
local repairBox = panel:addCheckBox(L['autorepair when visiting merchants']);
local sellBox = panel:addCheckBox(L['auto sell gray items when visiting merchants']);
local readableBox = panel:addCheckBox(L['skip readable items when autoselling']);

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    autoRepair = true,
    autoSell = true,
    autoSellSkipReadable = true,
  },
}).vars;

panel:OnLoad(function ()
  local options = saved.farmerOptions;

  repairBox:SetValue(options.autoRepair);
  sellBox:SetValue(options.autoSell);
  readableBox:SetValue(options.autoSellSkipReadable);
end);

panel:OnSave(function ()
  local options = saved.farmerOptions;

  options.autoRepair = repairBox:GetValue();
  options.autoSell = sellBox:GetValue();
  options.autoSellSkipReadable = readableBox:GetValue();
end);
