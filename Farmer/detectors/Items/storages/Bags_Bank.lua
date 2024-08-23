local _, addon = ...;

local Storage = addon.import('Class/Storage');
local C_Container = addon.import('polyfills/C_Container');

local EventUtils = addon.import('Utils/Events');

local wipe = _G.wipe;

local tinsert = _G.tinsert;

local GetContainerItemInfo = C_Container.GetContainerItemInfo;
local ContainerIDToInventoryID = C_Container.ContainerIDToInventoryID;
local GetContainerNumSlots = C_Container.GetContainerNumSlots;
local GetInventoryItemID = _G.GetInventoryItemID;
local GetInventoryItemLink = _G.GetInventoryItemLink;
local GetKeyRingSize = _G.GetKeyRingSize

local BagIndex = _G.Enum.BagIndex;
local InventoryConstants = _G.Constants.InventoryConstants;

local BACKPACK_CONTAINER = BagIndex.Backpack;
local BANK_CONTAINER = BagIndex.Bank;
local REAGENTBANK_CONTAINER = BagIndex.Reagentbank;
local KEYRING_CONTAINER = BagIndex.Keyring;

local NUM_BAG_SLOTS = InventoryConstants.NumBagSlots;
-- On Cataclysm Classic ReagentBag exists but not NumReagentBagSlots. Duh.
local NUM_REAGENTBAG_SLOTS = InventoryConstants.NumReagentBagSlots or 0;
local NUM_BANKBAGSLOTS = InventoryConstants.NumBankBagSlots;
local NUM_ACCOUNTBANK_SLOTS = InventoryConstants.NumAccountBankSlots;

local FIRST_BAG_SLOT = BagIndex.Bag_1;
local LAST_BAG_SLOT = FIRST_BAG_SLOT + NUM_BAG_SLOTS - 1;

local FIRST_REAGENTBAG_SLOT = BagIndex.ReagentBag;
local LAST_REAGENTBAG_SLOT = FIRST_REAGENTBAG_SLOT + NUM_REAGENTBAG_SLOTS - 1;

local FIRST_BANK_SLOT = BagIndex.BankBag_1;
local LAST_BANK_SLOT = FIRST_BANK_SLOT + NUM_BANKBAGSLOTS - 1;

local FIRST_ACCOUNTBANK_SLOT = NUM_ACCOUNTBANK_SLOTS and BagIndex.AccountBankTab_1 or nil;
local LAST_ACCOUNTBANK_SLOT = FIRST_ACCOUNTBANK_SLOT and FIRST_ACCOUNTBANK_SLOT + NUM_ACCOUNTBANK_SLOTS - 1;

local UNIT_PLAYER = 'player';

local bagSlots = {BACKPACK_CONTAINER};
local bankSlots = {REAGENTBANK_CONTAINER, BANK_CONTAINER};

local bagCache = {};
local flaggedBags = {};

for x = FIRST_BAG_SLOT, LAST_BAG_SLOT, 1 do
  tinsert(bagSlots, x);
end

for x = FIRST_REAGENTBAG_SLOT, LAST_REAGENTBAG_SLOT, 1 do
  tinsert(bagSlots, x);
end

if (GetKeyRingSize ~= nil) then
  tinsert(bagSlots, KEYRING_CONTAINER);
end

for x = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
  tinsert(bankSlots, x);
end

if (NUM_ACCOUNTBANK_SLOTS) then
  for x = FIRST_ACCOUNTBANK_SLOT, LAST_ACCOUNTBANK_SLOT, 1 do
    tinsert(bankSlots, x);
  end
end

local function getContainerSlotCount (bagIndex)
  if (bagIndex == KEYRING_CONTAINER) then
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

local function isBagSlot (bagIndex)
  return (FIRST_BAG_SLOT <= bagIndex and bagIndex <= LAST_BAG_SLOT);
end

local function isReagentBagSlot (bagIndex)
  return (FIRST_REAGENTBAG_SLOT <= bagIndex and bagIndex <= LAST_REAGENTBAG_SLOT);
end

local function isBankBagSlot (bagIndex)
  return (FIRST_BANK_SLOT <= bagIndex and bagIndex <= LAST_BANK_SLOT);
end

local function hasContainerSlot (bagIndex)
  return (isBagSlot(bagIndex)
          or isReagentBagSlot(bagIndex)
          or isBankBagSlot(bagIndex))
end

local function readContainerSlot (bagIndex)
  if (not hasContainerSlot(bagIndex)) then return end

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

local function clearBag (_, index)
  bagCache[index]:clearContent();
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
  local interactionFrameTypes = _G.Enum.PlayerInteractionType;
  local bankInteractionFrameTypes = {
    interactionFrameTypes.Banker,
    interactionFrameTypes.AccountBanker,
    interactionFrameTypes.CharacterBanker,
  };

  initInventory();

  addon.on('BAG_UPDATE', flagBag);
  addon.on('BAG_CLOSED', clearBag);
  addon.on('PLAYERBANKSLOTS_CHANGED', updateBankSlot);

  EventUtils.onInteractionFrameShow(bankInteractionFrameTypes, initBank);
  EventUtils.onInteractionFrameHide(bankInteractionFrameTypes, clearBank);

  if (_G.C_EventUtils.IsEventValid('PLAYERREAGENTBANKSLOTS_CHANGED')) then
    addon.on('PLAYERREAGENTBANKSLOTS_CHANGED', updateReagentBankSlot);
  end
end);

addon.Items.addStorage(function ()
  updateFlaggedBags();
  return bagCache;
end);
