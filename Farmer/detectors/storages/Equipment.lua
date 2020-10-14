local _, addon = ...;

local Storage = addon.Factory.Storage;
local Items = addon.Items;

local GetInventoryItemID = _G.GetInventoryItemID;
local GetInventoryItemLink = _G.GetInventoryItemLink;
local GetInventoryItemQuality = _G.GetInventoryItemQuality;
local INVSLOT_FIRST_EQUIPPED = _G.INVSLOT_FIRST_EQUIPPED;
local INVSLOT_LAST_EQUIPPED = _G.INVSLOT_LAST_EQUIPPED;
local INVSLOT_OFFHAND = _G.INVSLOT_OFFHAND;
local ITEM_QUALITY_ARTIFACT = _G.LE_ITEM_QUALITY_ARTIFACT or
    _G.Enum.ItemQuality.ARTIFACT;
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS;

local UNITID_PLAYER = 'player';

local currentEquipment = {};
local storage = Storage:new();

local function getEquipmentSlot (slot)
  local id = GetInventoryItemID(UNITID_PLAYER, slot);

  return id and {
    id = id,
    link = GetInventoryItemLink(UNITID_PLAYER, slot),
  };
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
  storage = Storage:new();

  for x = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED + NUM_BAG_SLOTS, 1 do
    local slotInfo = currentEquipment[x];

    if (slotInfo) then
      storage:addItem(slotInfo.id, slotInfo.link, 1);
    end
  end
end

local function checkSlotForArtifact (slot)
  local quality = GetInventoryItemQuality(UNITID_PLAYER, slot);

  if (quality == ITEM_QUALITY_ARTIFACT) then
    local id = GetInventoryItemID(UNITID_PLAYER, slot);
    local link = GetInventoryItemLink(UNITID_PLAYER, slot);

    Items.addItemToCurrentInventory(id, link, 1);
  end
end

addon.on('PLAYER_LOGIN', function ()
  currentEquipment = getEquipment();
  updateStorage();
  Items.updateCurrentInventory();
end);

addon.on('PLAYER_EQUIPMENT_CHANGED', function (slot, isEmpty)
  --[[ we need to do this because when equipping artifact weapons, a second item
         appears in the offhand slot --]]
  if (slot == INVSLOT_OFFHAND) then
    checkSlotForArtifact(INVSLOT_OFFHAND);
  end

  currentEquipment[slot] = (not isEmpty and getEquipmentSlot(slot)) or nil;

  updateStorage();
end);

Items.addStorage(function ()
  return {storage};
end);
