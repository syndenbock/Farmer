local _, addon = ...;

local Storage = addon.Factory.Storage;

local wipe = _G.wipe;
local GetContainerItemID = _G.GetContainerItemID;
local GetContainerItemInfo = _G.GetContainerItemInfo;
local ContainerIDToInventoryID = _G.ContainerIDToInventoryID;
local GetInventoryItemID = _G.GetInventoryItemID;
local GetInventoryItemLink = _G.GetInventoryItemLink;
local GetContainerNumSlots = _G.GetContainerNumSlots;
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS;
local NUM_BANKBAGSLOTS = _G.NUM_BANKBAGSLOTS;
local BANK_CONTAINER = _G.BANK_CONTAINER;
local REAGENTBANK_CONTAINER = _G.REAGENTBANK_CONTAINER;

local UNIT_PLAYER = 'player';
local FIRST_BAG_SLOT = 1;
local FIRST_BANK_SLOT = NUM_BAG_SLOTS + 1;
local LAST_BANK_SLOT = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS;
-- for some reason there is no constant for bank bag container
local BANKBAG_CONTAINER = -4;
local FIRST_SLOT = BANKBAG_CONTAINER;
local LAST_SLOT = LAST_BANK_SLOT;

local bagCache = {};
local flaggedBags = {};

local function getContainerSlotCount (bagIndex)
  -- For some reason GetContainerNumSlots returns 0 for BANKBAG_CONTAINER
  if (bagIndex == BANKBAG_CONTAINER) then
    return NUM_BANKBAGSLOTS;
  else
    return GetContainerNumSlots(bagIndex);
  end
end

local function initBagContent (bagIndex)
  if (bagCache[bagIndex] == nil) then
    bagCache[bagIndex] = Storage:new();
  end
end

local function isContainerSlot (bagIndex)
  return (FIRST_BAG_SLOT <= bagIndex and LAST_BANK_SLOT >= bagIndex);
end

local function readContainerSlot (bagIndex)
  if (not isContainerSlot(bagIndex)) then return end

  local inventoryIndex = ContainerIDToInventoryID(bagIndex);
  local id = GetInventoryItemID(UNIT_PLAYER, inventoryIndex);

  if (id) then
    bagCache[bagIndex]:setSlot(0, id, GetInventoryItemLink(UNIT_PLAYER, inventoryIndex), 1);
  else
    bagCache[bagIndex]:clearSlot(0);
  end
end

local function readBagSlot (bagIndex, slotIndex)
  --[[ GetContainerItemID has to be used, as GetContainerItemInfo returns
         nil if data is not ready --]]
  local id = GetContainerItemID(bagIndex, slotIndex);

  if (id) then
    local info = {GetContainerItemInfo(bagIndex, slotIndex)};
    local count = info[2];
    local link = info[7];

    bagCache[bagIndex]:setSlot(slotIndex, id, link, count);
  else
    bagCache[bagIndex]:clearSlot(slotIndex);
  end
end

local function updateBagCache (bagIndex)
  local slotCount = getContainerSlotCount(bagIndex);

  initBagContent(bagIndex);
  readContainerSlot(bagIndex);

  for slotIndex = 1, slotCount, 1 do
    readBagSlot(bagIndex, slotIndex);
  end
end

local function initBagCache (bagIndex)
  updateBagCache(bagIndex);
  bagCache[bagIndex]:clearChanges();
end

local function initInventory ()
  for x = FIRST_SLOT, LAST_SLOT, 1 do
    initBagCache(x);
  end

  if (REAGENTBANK_CONTAINER ~= nil) then
    initBagCache(REAGENTBANK_CONTAINER);
  end
end

--[[ function is used as event callback, so first argument is ignored ]]
local function flagBag (_, index)
  flaggedBags[index] = true;
end

local function updateFlaggedBags ()
  for bagIndex in pairs(flaggedBags) do
    updateBagCache(bagIndex);
  end

  wipe(flaggedBags);
end

local function initBank ()
  initBagCache(BANKBAG_CONTAINER);
  initBagCache(BANK_CONTAINER);

  for x = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
    initBagCache(x);
  end
end

--[[ function is used as event callback, so first argument is ignored ]]
local function updateBankSlot (_, slot)
  if (slot > GetContainerNumSlots(BANK_CONTAINER)) then
    return;
  end

  if (bagCache[BANK_CONTAINER]) then
    readBagSlot(BANK_CONTAINER, slot);
  end
end

local function clearBank ()
  bagCache[BANKBAG_CONTAINER] = nil;
  bagCache[BANK_CONTAINER] = nil;

  for x = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
    bagCache[x] = nil;
  end
end

--[[ function is used as event callback, so first argument is ignored ]]
local function updateReagentBankSlot (_, slot)
  readBagSlot(REAGENTBANK_CONTAINER, slot);
end

addon.onOnce('PLAYER_LOGIN', initInventory);
addon.on({'BAG_UPDATE', 'BAG_CLOSED'}, flagBag);
addon.on('BAG_UPDATE_DELAYED', updateFlaggedBags);

addon.on('BANKFRAME_OPENED', initBank);
addon.on('PLAYERBANKSLOTS_CHANGED', updateBankSlot);
addon.on({'BANKFRAME_CLOSED', 'PLAYER_ENTERING_WORLD'}, clearBank);

if (REAGENTBANK_CONTAINER) then
  addon.on('PLAYERREAGENTBANKSLOTS_CHANGED', updateReagentBankSlot);
end

addon.Items.addStorage(bagCache);
