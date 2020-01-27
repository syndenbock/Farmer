local addonName, addon = ...;

local UNITID_PLAYER = 'player';

local bagCache = {};
local currentInventory;
local flags = {
  loot = false,
  bagUpdate = false,
};

LootFrame:SetAlpha(0);

local function getFirstKey (table)
  return next(table, nil);
end

local function performAutoLoot ()
  local numloot = GetNumLootItems();

  for i = 1, numloot, 1 do
  -- for i = GetNumLootItems(), 1, -1 do
    local info = {GetLootSlotInfo(i)};
    local locked = info[6]

    if (not locked) then
      LootSlot(i);
    end
  end
end

local function checkItemDisplay (itemId, itemLink)
  if (itemId and
      farmerOptions.focusItems[itemId] == true) then
    if (farmerOptions.special == true) then
      return true
    end
  elseif (farmerOptions.focus == true) then
    return false
  end

  local itemName, _itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
        itemSubType, itemStackCount, itemEquipLoc, texture,
        itemSellPrice, itemClassID, itemSubClassID, bindType, expacID,
        itemSetID, isCraftingReagent = GetItemInfo(itemLink)

  -- happens when caging a pet or when looting mythic keystones
  if (itemName == nil) then
    return false
  end

  if (farmerOptions.reagents == true and
      isCraftingReagent == true) then
    return true
  end

  if (farmerOptions.questItems == true and
      (itemClassID == LE_ITEM_CLASS_QUESTITEM or
       itemClassID == LE_ITEM_CLASS_KEY)) then
    return true
  end

  if (farmerOptions.recipes == true and
      itemClassID == LE_ITEM_CLASS_RECIPE) then
    return true
  end

  if (farmerOptions.rarity == true and
      itemRarity >= farmerOptions.minimumRarity) then
    return true
  end

  return false
end

local function handleItem (itemId, itemLink, count)
  if (checkItemDisplay(itemId, itemLink) ~= true) then return end

  local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
        itemSubType, itemStackCount, itemEquipLoc, texture,
        itemSellPrice, itemClassID, itemSubClassID, bindType, expacID,
        itemSetID, isCraftingReagent = GetItemInfo(itemLink)

  local colors = {
    ITEM_QUALITY_COLORS[itemRarity].r,
    ITEM_QUALITY_COLORS[itemRarity].g,
    ITEM_QUALITY_COLORS[itemRarity].b,
  };

  -- crafting reagents
  if (isCraftingReagent == true) then
    if (itemId == chipId and hadChip == true) then
      hadChip = false
      return
    end

    colors = {0, 0.8, 0.8}
  end

  -- quest items
  if (itemClassID == LE_ITEM_CLASS_QUESTITEM or
      itemClassID == LE_ITEM_CLASS_KEY) then
    colors = {1, 0.8, 0, 1}
  end

  -- artifact relics
  if (itemClassID == LE_ITEM_CLASS_GEM and
      itemSubClassID == LE_ITEM_GEM_ARTIFACTRELIC) then -- gem / artifact relics
    local text

    itemLevel = GetDetailedItemLevelInfo(itemLink)
    text = addon:stringJoin({itemLevel, itemSubType}, ' ');
    addon.Print.printEquip(texture, itemName, text, count, colors)
    return
  end

  -- equippables
  if (itemEquipLoc ~= '') then
    -- bags
    if (itemClassID == LE_ITEM_CLASS_CONTAINER) then
      addon.Print.printEquip(texture, itemName, itemSubType, count, colors)
      return
    end

    -- weapons
    if (itemClassID == LE_ITEM_CLASS_WEAPON) then
      local text

      itemLevel = GetDetailedItemLevelInfo(itemLink)
      text = addon:stringJoin({itemLevel, itemSubType}, ' ');
      addon.Print.printEquip(texture, itemName, text, count, colors)
      return
    end

    -- armor
    if (itemClassID == LE_ITEM_CLASS_ARMOR) then
      local slot = _G[itemEquipLoc];
      local textList;
      local text;

      itemLevel = GetDetailedItemLevelInfo(itemLink);

      if (itemEquipLoc == 'INVTYPE_TABARD') then
        textList = {slot};
      elseif (itemEquipLoc ==  'INVTYPE_CLOAK') then
        textList = {itemLevel, slot};
      elseif (itemSubClassID == LE_ITEM_ARMOR_GENERIC) then
        textList = {itemLevel, slot} -- fingers/trinkets
      elseif (itemSubClassID > LE_ITEM_ARMOR_SHIELD) then -- we all know shields are offhand
        textList = {itemLevel, slot};
      else
        textList = {itemLevel, itemSubType, slot}
      end

      text = addon:stringJoin(textList, ' ');

      addon.Print.printEquip(texture, itemName, text, count, colors)
      return
    end
  end

  -- stackable items
  if (itemStackCount > 1) then
    addon.Print.printStackableItem(itemLink, texture, itemName, count, colors)
    return
  end

  -- all unspecified items
  addon.Print.printItem(texture, itemName, count, nil, colors, {forceName = true, minimumCount = 1})
end

--[[
///#############################################################################
/// Event listeners
///#############################################################################
]]--

addon:on('PLAYER_ENTERING_WORLD', function ()
  for key in pairs(flags) do
    flags[key] = false;
  end
end);

addon:on('LOOT_READY', function (lootSwitch)
  --[[ the LOOT_READY sometimes fires multiple times when looting, so we only
    handle it once until loot is closed ]]

  if (flags.loot == true) then return end
  flags.loot = true

  if (lootSwitch == true and
      farmerOptions.fastLoot == true) then
    performAutoLoot()
  else
    LootFrame:SetAlpha(1)
  end
end)

addon:on('LOOT_OPENED', function ()
  C_Timer.After(0, function ()
    if (flags.loot == true) then
      LootFrame:SetAlpha(1);
    end
  end);
end);

addon:on('LOOT_CLOSED', function ()
  flags.loot = false;

  LootFrame:Hide();
  LootFrame:SetAlpha(0);
end);

local function addItem (inventory, id, count, linkMap)
  if (inventory[id] == nil) then
    -- saving all links because gear has same ids, but different links
    inventory[id] = {
      links = linkMap,
      count = count,
    };
  else
    local itemInfo = inventory[id];

    itemInfo.count = itemInfo.count + count;

    for link in pairs(linkMap) do
      if (itemInfo.links[link] == nil) then
        itemInfo.links[link] = true;
      end
    end
  end
end

local function getBagContent (bagIndex)
  local bagContent = {};
  local slotCount = GetContainerNumSlots(bagIndex);

  for slotIndex = 1, slotCount, 1 do
    local id = GetContainerItemID(bagIndex, slotIndex);

    if (id ~= nil) then
      --[[ manually calculating the bag count is way faster than using
           GetItemCount --]]
      local _, count, _, _, _, _, link = GetContainerItemInfo(bagIndex, slotIndex);

      addItem(bagContent, id, count, {[link] = true});
    end
  end

  return bagContent;
end

local function getEquipment ()
  local equipment = {};

  -- slots 1-19 are gear, 20-23 are equipped bags
  for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED + NUM_BAG_SLOTS, 1 do
    local id = GetInventoryItemID(UNITID_PLAYER, i);

    if (id ~= nil) then
      local link = GetInventoryItemLink(UNITID_PLAYER, i) or id;

      addItem(equipment, id, 1, {[link] = true});
    end
  end

  return equipment;
end

local function getInventory ()
  local inventory = {};
  local equipment = getEquipment();

  for i = BACKPACK_CONTAINER, BACKPACK_CONTAINER + NUM_BAG_SLOTS, 1 do
    local bagContent = bagCache[i];

    if (bagContent ~= nil) then
      for itemId, itemInfo in pairs(bagContent) do
        addItem(inventory, itemId, itemInfo.count, itemInfo.links);
      end
    end
  end

  for itemId, itemInfo in pairs(equipment) do
    addItem(inventory, itemId, itemInfo.count, itemInfo.links);
  end

  return inventory;
end

local function checkInventory (timeStamp)
  timeStamp = timeStamp or GetTime();

  local inventory = getInventory();

  if (addon.Print.checkHideOptions() == false) then
    currentInventory = inventory;
    return;
  end

  local new = {};

  for id, info in pairs(inventory) do
    if (currentInventory[id] == nil) then
      new[id] = {
        count = inventory[id].count,
        link = getFirstKey(inventory[id].links)
      };
    elseif (inventory[id].count > currentInventory[id].count) then
      local links = inventory[id].links;
      local currentLinks = currentInventory[id].links;
      local found = false;

      for link, value in pairs(links) do
        if (currentLinks[link] == nil) then
          found = true;
          new[id] = {
            count = inventory[id].count - currentInventory[id].count,
            link = link
          };
          break;
        end
      end

      if (found == false) then
        new[id] = {
          count = inventory[id].count - currentInventory[id].count,
          link = getFirstKey(links)
        };
      end
    end
  end

  for id, info in pairs(new) do
    handleItem(id, info.link, info.count);
  end

  currentInventory = inventory;
end

addon:on('PLAYER_LOGIN', function ()
  for i = BACKPACK_CONTAINER, BACKPACK_CONTAINER + NUM_BAG_SLOTS, 1 do
    bagCache[i] = getBagContent(i);
  end

  currentInventory = getInventory();
end);

addon:on('BAG_UPDATE', function (bagIndex)
  if (bagIndex < BACKPACK_CONTAINER or
      bagIndex > BACKPACK_CONTAINER + NUM_BAG_SLOTS) then
    return;
  end

  bagCache[bagIndex] = getBagContent(bagIndex);
end);

addon:on('BAG_UPDATE_DELAYED', function ()
  if (flags.bagUpdate == true) then return end

  local stamp = GetTime();

  flags.bagUpdate = true;

  --[[ BAG_UPDATE_DELAYED may fire multiple times in one frame, so we only
       check bags once on the next frame --]]
  C_Timer.After(0, function ()
    checkInventory(stamp);
    flags.bagUpdate = false;
  end);
end);

local function checkSlotForArtifact (slot)
  local quality = GetInventoryItemQuality(UNITID_PLAYER, slot);

  if (quality == LE_ITEM_QUALITY_ARTIFACT) then
    local id = GetInventoryItemID(UNITID_PLAYER, slot);
    local link = GetInventoryItemLink(UNITID_PLAYER, slot);

    addItem(currentInventory, id, 1, {[link] = true});
  end
end

--[[ we need to do this because when equipping artifact weapons, a second item
     appears in the offhand slot --]]
addon:on('PLAYER_EQUIPMENT_CHANGED', function ()
  checkSlotForArtifact(INVSLOT_MAINHAND);
  checkSlotForArtifact(INVSLOT_OFFHAND);
end);

addon:slash('test', function (id, count)
  if (id ~= nil) then
    local _, link = GetItemInfo(id);
    count = tonumber(count or 1);
    handleItem(link, id, count);
    return;
  end

  local testItems = {
    2447, -- Peacebloom
    4496, -- Small Brown Pouch
    6975, -- Whirlwind Axe
    4322, -- Enchanter's Cowl
    13521, -- Recipe: Flask of Supreme Power
  };

  for i = 1, #testItems, 1 do
    local id = testItems[i];
    local _, link = GetItemInfo(id);

    handleItem(link, id, 1);
    handleItem(link, id, 4);
  end
end);
