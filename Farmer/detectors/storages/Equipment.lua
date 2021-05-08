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
    _G.Enum.ItemQuality.Artifact;

local UNITID_PLAYER = 'player';

local currentEquipment = Storage:new();

local function getEquipmentSlot (slot)
  local id = GetInventoryItemID(UNITID_PLAYER, slot);

  if (id == nil) then
    return nil;
  end

  return id, GetInventoryItemLink(UNITID_PLAYER, slot);
end

local function updateEquipmentSlot (slot)
  local id, link = getEquipmentSlot(slot);

  if (id == nil) then
    currentEquipment:clearSlot(slot);
    return;
  end

  currentEquipment:setSlot(slot, id, link, 1);
end

local function initEquipment ()
  for x = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED, 1 do
    updateEquipmentSlot(x);
  end

  currentEquipment:clearChanges();
end

local function checkSlotForArtifact (slot)
  local quality = GetInventoryItemQuality(UNITID_PLAYER, slot);

  if (quality == ITEM_QUALITY_ARTIFACT) then
    currentEquipment:clearSlot(slot);
  end
end

addon.onOnce('PLAYER_LOGIN', initEquipment);

addon.on('PLAYER_EQUIPMENT_CHANGED', function (slot, isEmpty)
  --[[ we need to do this because when equipping artifact weapons, a second item
         appears in the offhand slot --]]

  if (isEmpty) then
    currentEquipment:clearSlot(slot);
  else
    updateEquipmentSlot(slot);

    if (slot == INVSLOT_OFFHAND) then
      checkSlotForArtifact(INVSLOT_OFFHAND);
    end
  end
end);

Items.addStorage(function ()
  return {currentEquipment};
end);
