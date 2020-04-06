local addonName, addon = ...;

local addItem = addon.StorageUtils.addItem;
local Items = addon.Items;

local GetInventoryItemID = _G.GetInventoryItemID;
local GetInventoryItemLink = _G.GetInventoryItemLink;
local GetInventoryItemQuality = _G.GetInventoryItemQuality;
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS;
local INVSLOT_FIRST_EQUIPPED = _G.INVSLOT_FIRST_EQUIPPED;
local INVSLOT_LAST_EQUIPPED = _G.INVSLOT_LAST_EQUIPPED;
local INVSLOT_MAINHAND = _G.INVSLOT_MAINHAND;
local INVSLOT_OFFHAND = _G.INVSLOT_OFFHAND;
local LE_ITEM_QUALITY_ARTIFACT = _G.LE_ITEM_QUALITY_ARTIFACT;

local UNITID_PLAYER = 'player';

local currentEquipment = {};
local storage = {};

local function getEquipmentSlot (slot)
  local id = GetInventoryItemID(UNITID_PLAYER, slot);

  if (id ~= nil) then
    return {
      id = id,
      link = GetInventoryItemLink(UNITID_PLAYER, slot),
    };
  else
    return nil;
  end
end

local function getEquipment ()
  local equipment = {};

  -- slots 1-19 are gear, 20-23 are equipped bags
  for x = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED + NUM_BAG_SLOTS, 1 do
    equipment[x] = getEquipmentSlot(x);
  end

  return equipment;
end

local function updateStorage ()
  storage = {};

  for x = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED + NUM_BAG_SLOTS, 1 do
    local info = currentEquipment[x];

    if (info ~= nil) then
      addItem(storage, info.id, 1, info.link);
    end
  end
end

local function checkSlotForArtifact (slot)
  local quality = GetInventoryItemQuality(UNITID_PLAYER, slot);

  if (quality == LE_ITEM_QUALITY_ARTIFACT) then
    local id = GetInventoryItemID(UNITID_PLAYER, slot);
    local link = GetInventoryItemLink(UNITID_PLAYER, slot);

    Items:addItemToCurrentInventory(id, 1, link);
  end
end

addon:on('PLAYER_LOGIN', function ()
  currentEquipment = getEquipment();
  updateStorage();
  Items:updateCurrentInventory();
end);

addon:on('PLAYER_EQUIPMENT_CHANGED', function (slot, isEmpty)
  --[[ we need to do this because when equipping artifact weapons, a second item
         appears in the offhand slot --]]
  if (slot == INVSLOT_OFFHAND) then
    checkSlotForArtifact(INVSLOT_OFFHAND);
  end

  --[[ Seems like this is not needed, but will keep it here if a bug with
       artifact weapons occurs ]]
  -- checkSlotForArtifact(INVSLOT_MAINHAND);

  if (isEmpty == true) then
    currentEquipment[slot] = nil;
    updateStorage();
  else
    currentEquipment[slot] = getEquipmentSlot(slot);
    updateStorage();
  end
end);

Items:addStorage(function ()
  return {storage};
end);
