local addonName, addon = ...;

local UNITID_PLAYER = 'player';

local INVSLOT_MAINHAND = _G.INVSLOT_MAINHAND;
local INVSLOT_OFFHAND = _G.INVSLOT_OFFHAND;
local INVSLOT_FIRST_EQUIPPED = _G.INVSLOT_FIRST_EQUIPPED;
local INVSLOT_LAST_EQUIPPED = _G.INVSLOT_LAST_EQUIPPED;
local BANK_CONTAINER = _G.BANK_CONTAINER;
local REAGENTBANK_CONTAINER = _G.REAGENTBANK_CONTAINER;
local BACKPACK_CONTAINER = _G.BACKPACK_CONTAINER;
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS;
local NUM_BANKBAGSLOTS = _G.NUM_BANKBAGSLOTS;

local FIRST_SLOT = REAGENTBANK_CONTAINER ~= nil and REAGENTBANK_CONTAINER or BANK_CONTAINER;
local LAST_SLOT = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS;
local FIRST_BAG_SLOT = BACKPACK_CONTAINER;
local LAST_BAG_SLOT = BACKPACK_CONTAINER + NUM_BAG_SLOTS;
local FIRST_BANK_SLOT = NUM_BAG_SLOTS + 1;
local LAST_BANK_SLOT = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS;

local flaggedBags = {};
local bagCache = {};
local currentInventory;
local awaitedItems = nil;

local function getFirstKey (table)
  return next(table, nil);
end

local function flagBag (index)
  flaggedBags[index] = true;
end

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

local function awaitItem (id, bagIndex, slotIndex)
  if (awaitedItems == nil) then return end

  awaitedItems[id] = awaitedItems[id] or {};
  awaitedItems[id][bagIndex] = awaitedItems[id][bagIndex] or {};
  if (awaitedItems[id][bagIndex][slotIndex] == nil) then
    print('awaiting item:', id);
    awaitedItems[id][bagIndex][slotIndex] = true;
  end
end

local function updateBagCache (bagIndex)
  local bagContent = {};
  local slotCount = GetContainerNumSlots(bagIndex);

  if (awaitedItems ~= nil) then
    awaitedItems[bagIndex] = nil;
  end

  for slotIndex = 1, slotCount, 1 do
    --[[ GetContainerItemID has to be used, as GetContainerItemInfo returns
         nil if data is not ready --]]
    local id = GetContainerItemID(bagIndex, slotIndex);

    if (id ~= nil) then
      --[[ Manually calculating the bag count is way faster than using
           GetItemCount --]]
      local name, count, _, _, _, _, link, _, _, _id = GetContainerItemInfo(bagIndex, slotIndex);

      if (name == nil) then
        --print('no information for bag item available');
        awaitItem(id, bagIndex, slotIndex);
      else
        addItem(bagContent, id, count, {[link] = true});
      end
    end
  end

  bagCache[bagIndex] = bagContent;
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

local function getCachedInventory ()
  local inventory = {};
  local equipment = getEquipment();

  for bagIndex, bagContent in pairs(bagCache) do
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

local function updateFlaggedBags ()
  for bagIndex in pairs(flaggedBags) do
    updateBagCache(bagIndex);
  end

  flaggedBags = {};
end

local function checkInventory ()
  local inventory;

  updateFlaggedBags();
  inventory = getCachedInventory();

  if (currentInventory == nil) then
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
    addon:yell('NEW_ITEM', id, info.link, info.count);
  end

  currentInventory = inventory;
end

local function checkAwaitedItems (itemId)
  if (awaitedItems == nil) then return end

  local bagMap = awaitedItems[itemId];

  if (bagMap == nil) then return end

  for bagIndex, slotMap in pairs(bagMap) do
    local bagContent = bagCache[bagIndex];

    for slotIndex in pairs(slotMap) do
      local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(bagIndex, slotIndex);

      addItem(bagContent, id, count, {[link] = true});
      --print('received awaited item:', itemId);
    end
  end

  checkInventory();
end

local function initInventory ()
  bagCache = {};
  flaggedBags = {};

  for i = FIRST_BAG_SLOT, LAST_BAG_SLOT, 1 do
    updateBagCache(i);
  end

  currentInventory = getCachedInventory();
  awaitedItems = {};
end

local function checkSlotForArtifact (slot)
  local quality = GetInventoryItemQuality(UNITID_PLAYER, slot);

  if (quality == LE_ITEM_QUALITY_ARTIFACT) then
    local id = GetInventoryItemID(UNITID_PLAYER, slot);
    local link = GetInventoryItemLink(UNITID_PLAYER, slot);

    addItem(currentInventory, id, 1, {[link] = true});
  end
end

addon:on('PLAYER_LOGIN', initInventory);

addon:on('BANKFRAME_OPENED', function ()
  for index = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
    updateBagCache(index);
  end

  updateBagCache(BANK_CONTAINER);

  if (not addon:isClassic()) then
    updateBagCache(REAGENTBANK_CONTAINER);
  end

  currentInventory = getCachedInventory();
end);

--[[ BANKFRAME_CLOSED fires multiple times and bank slots are still available
     on the event frame, so we funnel to execute only once on the next
     frame --]]
addon:funnel('BANKFRAME_CLOSED', function ()
  for index = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
    bagCache[index] = nil
  end

  bagCache[BANK_CONTAINER] = nil;
  if (not addon:isClassic()) then
    bagCache[REAGENTBANK_CONTAINER] = nil;
  end

  currentInventory = getCachedInventory();
end);

addon:on('BAG_UPDATE', function (bagIndex)
  flagBag(bagIndex);
end);

addon:on('PLAYERBANKSLOTS_CHANGED', function ()
  flagBag(BANK_CONTAINER);
end);

if (addon:isClassic() == false) then
  addon:on('PLAYERREAGENTBANKSLOTS_CHANGED', function ()
    flagBag(REAGENTBANK_CONTAINER);
  end);
end

addon:on('BAG_UPDATE_DELAYED', checkInventory);

addon:on('GET_ITEM_INFO_RECEIVED', checkAwaitedItems);

--[[ we need to do this because when equipping artifact weapons, a second item
     appears in the offhand slot --]]
addon:on('PLAYER_EQUIPMENT_CHANGED', function ()
  checkSlotForArtifact(INVSLOT_MAINHAND);
  checkSlotForArtifact(INVSLOT_OFFHAND);
end);
