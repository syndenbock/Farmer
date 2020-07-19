local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Sell and Repair'], addon.mainPanel);
local repairBox = panel:addCheckBox(L['autorepair when visiting merchants']);

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    autoRepair = true,
  },
}).vars;

panel:OnLoad(function ()
  local options = saved.farmerOptions;

  repairBox:SetValue(options.autoRepair);
end);

panel:OnSave(function ()
  local options = saved.farmerOptions;

  options.autoRepair = repairBox:GetValue();
end);
