local addonName, addon = ...;

local lootIsOpen = false;

LootFrame:SetAlpha(0);

local function performAutoLoot ()
  local numloot = GetNumLootItems();

  for i = 1, numloot, 1 do
  -- for i = GetNumLootItems(), 1, -1 do
  -- for i = 1, GetNumLootItems(), 1 do
    local info = {GetLootSlotInfo(i)};
    local locked = info[6];

    if (not locked) then
      LootSlot(i);
    end
  end
end

addon:on('LOOT_READY', function (lootSwitch)
  --[[ the LOOT_READY sometimes fires multiple times when looting, so we only
    handle it once until loot is closed ]]
  if (lootIsOpen == true) then return end

  lootIsOpen = true

  if (lootSwitch == true and
      farmerOptions.fastLoot == true) then
    performAutoLoot();
  else
    LootFrame:SetAlpha(1);
  end
end);

addon:on('LOOT_OPENED', function ()
  LootFrame:SetAlpha(1);
end);

addon:on('LOOT_CLOSED', function ()
  lootIsOpen = false;

  LootFrame:SetAlpha(0);
end);

addon:on('PLAYER_ENTERING_WORLD', function ()
  lootIsOpen = false;
end);
