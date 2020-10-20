local _, addon = ...;

local Storage = addon.Factory.Storage;
local Items = addon.Items;

local GetInventoryItemLink = _G.GetInventoryItemLink;
local GetInventoryItemQuality = _G.GetInventoryItemQuality;
local INVSLOT_FIRST_EQUIPPED = _G.INVSLOT_FIRST_EQUIPPED;
local INVSLOT_LAST_EQUIPPED = _G.INVSLOT_LAST_EQUIPPED;
local INVSLOT_OFFHAND = _G.INVSLOT_OFFHAND;
local ITEM_QUALITY_ARTIFACT = _G.LE_ITEM_QUALITY_ARTIFACT or
    _G.Enum.ItemQuality.Artifact;
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS;

local UNITID_PLAYER = 'player';

local currentEquipment = {};
local storage = Storage:new();

local function getEquipmentSlot (slot)
  return GetInventoryItemLink(UNITID_PLAYER, slot);
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

  for _, itemLink in pairs(currentEquipment) do
    storage:addItem(itemLink, 1);
  end
end

local function checkSlotForArtifact (slot)
  local quality = GetInventoryItemQuality(UNITID_PLAYER, slot);

  if (quality == ITEM_QUALITY_ARTIFACT) then
    local link = GetInventoryItemLink(UNITID_PLAYER, slot);

    if (link) then
      Items.addItemToCurrentInventory(link, 1);
    end
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

  if (isEmpty) then
    currentEquipment[slot] = nil;
  else
    currentEquipment[slot] = getEquipmentSlot(slot);

    if (slot == INVSLOT_OFFHAND) then
      checkSlotForArtifact(INVSLOT_OFFHAND);
    end
  end

  updateStorage();
end);

Items.addStorage(function ()
  return {storage};
end);
