local addonName, addon = ...;

local L = addon.L;

local IsEventValid = _G.C_EventUtils.IsEventValid

local panel = addon.import('Class/Options/Panel'):new(L['Misc'], addon.mainPanel);

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
  hideLootToasts = panel:addCheckBox(L['hide loot and item roll toasts']),
});

local lootAlertEvents = { 'SHOW_LOOT_TOAST', 'SHOW_LOOT_TOAST_UPGRADE',
  'BONUS_ROLL_RESULT', 'LOOT_ITEM_ROLL_WON' }

local function applyOptions()
  local AlertFrame = _G.AlertFrame;
  local usedFunction = (options.hideLootToasts and AlertFrame.UnregisterEvent) or AlertFrame.RegisterEvent

  for _, event in ipairs(lootAlertEvents) do
    if (IsEventValid(event)) then
      usedFunction(AlertFrame, event);
    end
  end
end

panel:OnSave(applyOptions);
panel:OnCancel(applyOptions);
saved:OnLoad(applyOptions);
