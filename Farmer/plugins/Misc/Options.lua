local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Misc'], addon.mainPanel);

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    fastLoot = true,
    hidePlatesWhenFishing = true,
  },
}).vars.farmerOptions;

panel:mapOptions(options, {
  fastLoot = panel:addCheckBox(L['enable fast autoloot']),
  hidePlatesWhenFishing =
      panel:addCheckBox(L['hide health bars while fishing']),
});
