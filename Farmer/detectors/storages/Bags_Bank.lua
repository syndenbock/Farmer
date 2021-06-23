local _, addon = ...;

local Items = addon.Items;
local Storage = addon.Factory.Storage;

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

local function flagBag (index)
  flaggedBags[index] = true;
end

local function readBagSlot (bagContent, bagIndex, slotIndex)
  --[[ GetContainerItemID has to be used, as GetContainerItemInfo returns
         nil if data is not ready --]]
  local id = GetContainerItemID(bagIndex, slotIndex);

  if (not id) then
    bagContent:clearSlot(slotIndex);
    return;
  end

  local info = {GetContainerItemInfo(bagIndex, slotIndex)};
  local count = info[2];
  local link = info[7];

  bagContent:setSlot(slotIndex, id, link, count);
end

local function isContainerSlot (bagIndex)
  return FIRST_BAG_SLOT <= bagIndex and LAST_BANK_SLOT >= bagIndex;
end

local function readContainerSlot (bagContent, bagIndex)
  if (not isContainerSlot(bagIndex)) then return end

  local inventoryIndex = ContainerIDToInventoryID(bagIndex);
  local id = GetInventoryItemID(UNIT_PLAYER, inventoryIndex);

  if (not id) then
    bagContent:clearSlot(0);
    return;
  end

  bagContent:setSlot(0, id, GetInventoryItemLink(UNIT_PLAYER, inventoryIndex), 1);
end

local function getContainerSlotCount (bagIndex)
  -- For some reason GetContainerNumSlots returns 0 for BANKBAG_CONTAINER
  return (bagIndex == BANKBAG_CONTAINER and NUM_BANKBAGSLOTS) or
    GetContainerNumSlots(bagIndex);
end

local function initBagContent (bagIndex)
  local bagContent = bagCache[bagIndex];

  if (bagContent == nil) then
    bagContent = Storage:new();
    bagCache[bagIndex] = bagContent;
  end

  return bagContent;
end

local function updateBagCache (bagIndex)
  local slotCount = getContainerSlotCount(bagIndex);
  local bagContent = initBagContent(bagIndex);

  readContainerSlot(bagContent, bagIndex);

  for slotIndex = 1, slotCount, 1 do
    readBagSlot(bagContent, bagIndex, slotIndex);
  end

  return bagContent;
end

local function initBagCache (bagIndex)
  updateBagCache(bagIndex):clearChanges();
end

local function updateFlaggedBags ()
  for bagIndex in pairs(flaggedBags) do
    updateBagCache(bagIndex);
  end

  flaggedBags = {};
end

local function initInventory ()
  for x = FIRST_SLOT, LAST_SLOT, 1 do
    initBagCache(x);
  end

  if (REAGENTBANK_CONTAINER ~= nil) then
    initBagCache(REAGENTBANK_CONTAINER);
  end
end

addon.onOnce('PLAYER_LOGIN', initInventory);

addon.on('BANKFRAME_OPENED', function ()
  initBagCache(BANKBAG_CONTAINER);
  initBagCache(BANK_CONTAINER);

  for x = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
    initBagCache(x);
  end
end);

addon.on({'BANKFRAME_CLOSED', 'PLAYER_ENTERING_WORLD'}, function ()
  bagCache[BANKBAG_CONTAINER] = nil;
  bagCache[BANK_CONTAINER] = nil;

  for x = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
    bagCache[x] = nil;
  end
end);

addon.on({'BAG_UPDATE', 'BAG_CLOSED'}, flagBag);

addon.on('PLAYERBANKSLOTS_CHANGED', function (slot)
  local maxSlot = GetContainerNumSlots(BANK_CONTAINER);
  local bagSlot, bagContent;

  if (slot <= maxSlot) then
    bagSlot = BANK_CONTAINER;
  else
    slot = slot - maxSlot;
    bagSlot = BANKBAG_CONTAINER;
  end

  bagContent = bagCache[bagSlot];

  if (bagContent ~= nil) then
    readBagSlot(bagContent, bagSlot, slot)
  end
end);

if (REAGENTBANK_CONTAINER ~= nil) then
  addon.on('PLAYERREAGENTBANKSLOTS_CHANGED', function (slot)
    readBagSlot(bagCache[REAGENTBANK_CONTAINER], REAGENTBANK_CONTAINER, slot);
  end);
end

addon.on('BAG_UPDATE_DELAYED', updateFlaggedBags);

Items.addStorage(bagCache);
