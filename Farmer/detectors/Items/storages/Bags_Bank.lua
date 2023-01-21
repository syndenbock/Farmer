local _, addon = ...;

local Storage = addon.import('Class/Storage');
local C_Container = addon.import('polyfills/C_Container');

local wipe = _G.wipe;
local tinsert = _G.tinsert;

local GetContainerItemInfo = C_Container.GetContainerItemInfo;
local ContainerIDToInventoryID = C_Container.ContainerIDToInventoryID;
local GetContainerNumSlots = C_Container.GetContainerNumSlots;
local GetInventoryItemID = _G.GetInventoryItemID;
local GetInventoryItemLink = _G.GetInventoryItemLink;
local GetKeyRingSize = _G.GetKeyRingSize;

local BACKPACK_CONTAINER = _G.BACKPACK_CONTAINER;
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS;
local NUM_BANKBAGSLOTS = _G.NUM_BANKBAGSLOTS;
local BANK_OFFSET = (addon.isRetail() and 5) or 4;
local BANK_CONTAINER = _G.BANK_CONTAINER or -1;
local REAGENTBANK_CONTAINER = _G.REAGENTBANK_CONTAINER or -3;
local REAGENT_CONTAINER = _G.REAGENT_CONTAINER or 5;
local KEYRING_CONTAINER = _G.KEYRING_CONTAINER or -2;
-- for some reason there is no constant for bank bag container
local BANKBAG_CONTAINER = -4;
local LAST_BANK_SLOT = BANK_OFFSET + NUM_BANKBAGSLOTS;
local UNIT_PLAYER = 'player';

local bagSlots = {BACKPACK_CONTAINER};
local bankSlots = {BANKBAG_CONTAINER, BANK_CONTAINER};

local bagCache = {};
local flaggedBags = {};

for x = 1, NUM_BAG_SLOTS, 1 do
  tinsert(bagSlots, x);
end

for x = BANK_OFFSET + 1, LAST_BANK_SLOT, 1 do
  tinsert(bankSlots, x);
end

if (addon.isRetail()) then
  tinsert(bagSlots, REAGENT_CONTAINER);
  tinsert(bankSlots, REAGENTBANK_CONTAINER);
else
  tinsert(bagSlots, KEYRING_CONTAINER);
end

local function getContainerSlotCount (bagIndex)
  -- For some reason GetContainerNumSlots returns 0 for BANKBAG_CONTAINER
  if (bagIndex == BANKBAG_CONTAINER) then
    return NUM_BANKBAGSLOTS;
  elseif (bagIndex == KEYRING_CONTAINER) then
    return GetKeyRingSize();
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
  return (BACKPACK_CONTAINER < bagIndex and bagIndex <= LAST_BANK_SLOT);
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
  local info = GetContainerItemInfo(bagIndex, slotIndex);

  if (info ~= nil) then
    bagCache[bagIndex]:setSlot(slotIndex, info.itemID, info.hyperlink, info.stackCount);
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
  for _, index in ipairs(bagSlots) do
    initBagCache(index);
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
  for _, x in ipairs(bankSlots) do
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
  for _, x in ipairs(bankSlots) do
    bagCache[x] = nil;
  end
end

--[[ function is used as event callback, so first argument is ignored ]]
local function updateReagentBankSlot (_, slot)
  if (bagCache[REAGENTBANK_CONTAINER] ~= nil) then
    readBagSlot(REAGENTBANK_CONTAINER, slot);
  end
end

addon.onOnce('PLAYER_LOGIN', function ()
  initInventory();

  addon.on({'BAG_UPDATE', 'BAG_CLOSED'}, flagBag);
  addon.on('BANKFRAME_OPENED', initBank);
  addon.on('PLAYERBANKSLOTS_CHANGED', updateBankSlot);
  addon.on({'BANKFRAME_CLOSED', 'PLAYER_ENTERING_WORLD'}, clearBank);

  if (addon.isRetail()) then
    addon.on('PLAYERREAGENTBANKSLOTS_CHANGED', updateReagentBankSlot);
  end
end);

addon.Items.addStorage(function ()
  updateFlaggedBags();
  return bagCache;
end);
