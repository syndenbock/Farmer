local _, addon = ...;

local GetInventoryItemID = _G.GetInventoryItemID;
local GetInventoryItemLink = _G.GetInventoryItemLink;
local GetInventoryItemQuality = _G.GetInventoryItemQuality;
local INVSLOT_FIRST_EQUIPPED = _G.INVSLOT_FIRST_EQUIPPED;
local INVSLOT_LAST_EQUIPPED = _G.INVSLOT_LAST_EQUIPPED;
local INVSLOT_OFFHAND = _G.INVSLOT_OFFHAND;
local ITEM_QUALITY_ARTIFACT = _G.Enum.ItemQuality.Artifact;

local UNITID_PLAYER = 'player';

local currentEquipment = addon.Class.Storage:new();

local function isSlotArtifactOffhand (slot)
  return (slot == INVSLOT_OFFHAND and
      GetInventoryItemQuality(UNITID_PLAYER, slot) == ITEM_QUALITY_ARTIFACT);
end

local function getEquipmentSlot (slot)
  local id = GetInventoryItemID(UNITID_PLAYER, slot);

  if (id) then
    return id, GetInventoryItemLink(UNITID_PLAYER, slot);
  else
    return nil, nil;
  end
end

local function updateEquipmentSlot (slot)
  if (isSlotArtifactOffhand(slot)) then
    currentEquipment:clearSlot(slot);
    return;
  end

  local id, link = getEquipmentSlot(slot);

  if (id) then
    currentEquipment:setSlot(slot, id, link, 1);
  else
    currentEquipment:clearSlot(slot);
  end
end

local function updateEquipment ()
  for x = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED, 1 do
    updateEquipmentSlot(x);
  end
end

local function initEquipment ()
  updateEquipment();
  currentEquipment:clearChanges();
end

local function handleSlotUpdate (_, slot, isEmpty)
  if (isEmpty) then
    currentEquipment:clearSlot(slot);
  else
    updateEquipmentSlot(slot);
  end
end

addon.onOnce('PLAYER_LOGIN', initEquipment);
-- this is needed to detect gear updates when automatically switching specs
-- when joining an LFG instance
addon.on('EQUIPMENT_SWAP_FINISHED', updateEquipment);
addon.on('PLAYER_EQUIPMENT_CHANGED', handleSlotUpdate);

addon.Items.addStorage({currentEquipment});
