local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionClass.Panel:new(L['Sell and Repair'],
    addon.mainPanel);

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    SellAndRepair = {
      autoRepair = true,
      autoRepairAllowGuild = false,
      autoSell = true,
      autoSellSkipReadable = true,
    },
  },
}).vars.farmerOptions.SellAndRepair;

panel:mapOptions(options, {
  autoRepair = panel:addCheckBox(L['autorepair when visiting merchants']),
  autoRepairAllowGuild =
      panel:addCheckBox(L['allow using guild funds for autorepair']),
  autoSell =
      panel:addCheckBox(L['autosell gray items when visiting merchants']),
  autoSellSkipReadable =
      panel:addCheckBox(L['skip readable items when autoselling']),
});
