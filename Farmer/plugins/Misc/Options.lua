local addonName, addon = ...;

local L = addon.L;

local AlertFrame = _G.AlertFrame;

local panel = addon.OptionClass.Panel:new(L['Misc'], addon.mainPanel);

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Misc = {
      fastLoot = true,
      hidePlatesWhenFishing = true,
      hideLootToasts = false,
    },
  },
});
local options = saved.vars.farmerOptions.Misc;

panel:mapOptions(options, {
  fastLoot = panel:addCheckBox(L['enable fast autoloot']),
  hidePlatesWhenFishing = panel:addCheckBox(L['hide health bars while fishing']),
  hideLootToasts = panel:addCheckBox(L['hide loot and item roll toasts']);
});

local function applyOptions ()
  if (options.hideLootToasts == true) then
    if (not addon.isClassic()) then
      AlertFrame:UnregisterEvent('SHOW_LOOT_TOAST')
      AlertFrame:UnregisterEvent('SHOW_LOOT_TOAST_UPGRADE')
      AlertFrame:UnregisterEvent('BONUS_ROLL_RESULT')
    end

    AlertFrame:UnregisterEvent('LOOT_ITEM_ROLL_WON')
  else
    if (not addon.isClassic()) then
      AlertFrame:RegisterEvent('SHOW_LOOT_TOAST')
      AlertFrame:RegisterEvent('SHOW_LOOT_TOAST_UPGRADE')
      AlertFrame:RegisterEvent('BONUS_ROLL_RESULT')
    end

    AlertFrame:RegisterEvent('LOOT_ITEM_ROLL_WON')
  end
end

panel:OnSave(applyOptions);
panel:OnCancel(applyOptions);
saved:OnLoad(applyOptions);
