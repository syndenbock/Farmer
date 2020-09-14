local addonName, addon = ...;

local GetNumLootItems = _G.GetNumLootItems;
local GetLootSlotInfo = _G.GetLootSlotInfo;
local LootSlot = _G.LootSlot;

local lootIsOpen = false;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Misc;

local function autoLootSlot (slot)
  local info = {GetLootSlotInfo(slot)};
  local locked = info[6];

  if (not locked) then
    LootSlot(slot);
  end
end

local function performAutoLoot ()
  for x = 1, GetNumLootItems(), 1 do
    autoLootSlot(x);
  end
end

addon.on('LOOT_READY', function (autoLoot)
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
