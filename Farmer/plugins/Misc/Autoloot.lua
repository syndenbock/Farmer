local addonName, addon = ...;

local GetNumLootItems = _G.GetNumLootItems;
local GetLootSlotInfo = _G.GetLootSlotInfo;
local LootSlot = _G.LootSlot;
local LootFrame = _G.LootFrame;

local lootIsOpen = false;

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

LootFrame:SetAlpha(0);

local function autoLootSlot (slot)
  local info = {GetLootSlotInfo(slot)};
  local locked = info[6];

  if (not locked) then
    LootSlot(slot);
  end
end

local function performAutoLoot ()
  for x = 1, GetNumLootItems(), 1 do
  -- for i = GetNumLootItems(), 1, -1 do
    autoLootSlot(x);
  end
end

addon.on('LOOT_READY', function (autoLoot)
  --[[ the LOOT_READY sometimes fires multiple times when looting, so we only
    handle it once until loot is closed ]]
  if (lootIsOpen == true) then return end

  lootIsOpen = true;

  if (autoLoot and saved.farmerOptions.fastLoot == true) then
    performAutoLoot();
  else
    LootFrame:SetAlpha(1);
  end
end);

addon.on('LOOT_OPENED', function ()
  LootFrame:SetAlpha(1);
end);

addon.on('LOOT_CLOSED', function ()
  lootIsOpen = false;

  LootFrame:SetAlpha(0);
end);

addon.on('PLAYER_ENTERING_WORLD', function ()
  lootIsOpen = false;
end);
