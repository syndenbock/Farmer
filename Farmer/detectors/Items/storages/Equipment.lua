local _, addon = ...;

local GetInventoryItemID = _G.GetInventoryItemID;
local GetInventoryItemLink = _G.GetInventoryItemLink;
local GetInventoryItemQuality = _G.GetInventoryItemQuality;
local INVSLOT_OFFHAND = _G.INVSLOT_OFFHAND;
local ITEM_QUALITY_ARTIFACT = _G.Enum.ItemQuality.Artifact;

local FIRST_INVENTORY_SLOT = 1;
local LAST_INVENTORY_SLOT = (addon.isRetail() and 30) or 19;
local UNITID_PLAYER = 'player';

local currentEquipment = addon.import('Class/Storage'):new();

local function isSlotArtifactOffhand (slot)
  return (slot == INVSLOT_OFFHAND and
      GetInventoryItemQuality(UNITID_PLAYER, slot) == ITEM_QUALITY_ARTIFACT);
end

local function getEquipmentSlot (slot)
  local id = GetInventoryItemID(UNITID_PLAYER, slot);

  if (id and id ~= 0) then
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
  for x = FIRST_INVENTORY_SLOT, LAST_INVENTORY_SLOT, 1 do
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

addon.onOnce('PLAYER_LOGIN', function ()
  initEquipment();
  -- This is needed to detect gear updates when automatically switching specs
  -- when joining an LFG instance.
  -- EQUIPMENT_SWAP_FINISHED does not work for some reason.
  addon.on('PLAYER_ENTERING_WORLD', updateEquipment);
  addon.on('PLAYER_EQUIPMENT_CHANGED', handleSlotUpdate);
end);

addon.Items.addStorage({currentEquipment});
