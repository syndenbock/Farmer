local _, addon = ...;

local Storage = addon.import('Class/Storage');
local C_Container = addon.import('polyfills/C_Container');

local wipe = _G.wipe;
local GetContainerItemInfo = C_Container.GetContainerItemInfo;
local ContainerIDToInventoryID = C_Container.ContainerIDToInventoryID;
local GetContainerNumSlots = C_Container.GetContainerNumSlots;
local GetInventoryItemID = _G.GetInventoryItemID;
local GetInventoryItemLink = _G.GetInventoryItemLink;
local BACKPACK_CONTAINER = _G.BACKPACK_CONTAINER;
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS;
local NUM_BANKBAGSLOTS = _G.NUM_BANKBAGSLOTS;
local BANK_CONTAINER = _G.BANK_CONTAINER;
local REAGENTBANK_CONTAINER = _G.REAGENTBANK_CONTAINER;

local UNIT_PLAYER = 'player';
local FIRST_BANK_SLOT = _G.ITEM_INVENTORY_BANK_BAG_OFFSET	+ 1;
local LAST_BANK_SLOT = _G.ITEM_INVENTORY_BANK_BAG_OFFSET + NUM_BANKBAGSLOTS;
-- for some reason there is no constant for bank bag container
local BANKBAG_CONTAINER = -4;

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
  for x = BACKPACK_CONTAINER, NUM_BAG_SLOTS, 1 do
    initBagCache(x);
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

  if (REAGENTBANK_CONTAINER ~= nil) then
    initBagCache(REAGENTBANK_CONTAINER);
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

  if (REAGENTBANK_CONTAINER ~= nil) then
    bagCache[REAGENTBANK_CONTAINER] = nil
  end

  for x = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
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
  addon.on('BAG_UPDATE_DELAYED', updateFlaggedBags);

  addon.on('BANKFRAME_OPENED', initBank);
  addon.on('PLAYERBANKSLOTS_CHANGED', updateBankSlot);
  addon.on({'BANKFRAME_CLOSED', 'PLAYER_ENTERING_WORLD'}, clearBank);

  if (REAGENTBANK_CONTAINER ~= nil) then
    addon.on('PLAYERREAGENTBANKSLOTS_CHANGED', updateReagentBankSlot);
  end
end);

addon.Items.addStorage(bagCache);
