local addonName, addon = ...;

local GetLootInfo = _G.GetLootInfo;
local LootSlot = _G.LootSlot;

local lootIsOpen = false;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Misc;

local function performAutoLoot ()
  for x, info in ipairs(GetLootInfo()) do
    if (not info.locked) then
      LootSlot(x);
    end
  end
end

addon.on('LOOT_READY', function (_, autoLoot)
  --[[ the LOOT_READY sometimes fires multiple times when looting, so we only
    handle it once until loot is closed ]]
  if (lootIsOpen == true) then
    return;
  end

  lootIsOpen = true;

  if (autoLoot and options.fastLoot == true) then
    performAutoLoot();
  end
end);

addon.on({'LOOT_CLOSED', 'PLAYER_ENTERING_WORLD'}, function ()
  lootIsOpen = false;
end);
