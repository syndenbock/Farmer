local addonName, addon = ...;

local L = addon.L;

local panel = addon.import('Class/Options/Panel'):new(L['Sell and Repair'],
    addon.mainPanel);

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    SellAndRepair = {
      autoRepair = true,
      autoRepairAllowGuild = true,
      autoSell = true,
      autoSellSkipReadable = true,
    },
  },
}).vars.farmerOptions.SellAndRepair;

do
  local optionMap = {};

  optionMap.autoRepair = panel:addCheckBox(L['autorepair when visiting merchants']);

  if (_G.CanGuildBankRepair ~= nil) then
    optionMap.autoRepairAllowGuild =
        panel:addCheckBox(L['allow using guild funds for autorepair']);
  end

  optionMap.autoSell =
      panel:addCheckBox(L['autosell gray items when visiting merchants']);
  optionMap.autoSellSkipReadable =
      panel:addCheckBox(L['skip readable items when autoselling']);

  panel:mapOptions(options, optionMap);
end
