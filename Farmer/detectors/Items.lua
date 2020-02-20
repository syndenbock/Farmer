local addonName, addon = ...;

local UNITID_PLAYER = 'player';

local FIRST_SLOT = BANK_CONTAINER;
local LAST_SLOT = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS;

local bagCache = {};
local currentInventory;

local function getFirstKey (table)
  return next(table, nil);
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

local function getCachedInventory ()
  local inventory = {};
  local equipment = getEquipment();

  for i = FIRST_SLOT, LAST_SLOT, 1 do
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

local function getInventory ()
  bagCache = {};

  for i = FIRST_SLOT, LAST_SLOT, 1 do
    bagCache[i] = getBagContent(i);
  end

  return getCachedInventory();
end

local function checkInventory ()
  local inventory = getCachedInventory();
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

local function checkSlotForArtifact (slot)
  local quality = GetInventoryItemQuality(UNITID_PLAYER, slot);

  if (quality == LE_ITEM_QUALITY_ARTIFACT) then
    local id = GetInventoryItemID(UNITID_PLAYER, slot);
    local link = GetInventoryItemLink(UNITID_PLAYER, slot);

    addItem(currentInventory, id, 1, {[link] = true});
  end
end

addon:on({'PLAYER_LOGIN', 'BANKFRAME_OPENED', 'BANKFRAME_CLOSED'}, function ()
  currentInventory = getInventory();
end);

addon:on('BAG_UPDATE', function (bagIndex)
  bagCache[bagIndex] = getBagContent(bagIndex);
end);

addon:on('BAG_UPDATE_DELAYED', checkInventory);

--[[ we need to do this because when equipping artifact weapons, a second item
     appears in the offhand slot --]]
addon:on('PLAYER_EQUIPMENT_CHANGED', function ()
  checkSlotForArtifact(INVSLOT_MAINHAND);
  checkSlotForArtifact(INVSLOT_OFFHAND);
end);
