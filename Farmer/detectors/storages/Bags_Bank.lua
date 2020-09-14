local _, addon = ...;

local Items = addon.Items;
local Storage = addon.Factory.Storage;

local BANK_CONTAINER = _G.BANK_CONTAINER;
local GetContainerItemID = _G.GetContainerItemID;
local GetContainerItemInfo = _G.GetContainerItemInfo;
local GetContainerNumSlots = _G.GetContainerNumSlots;
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS;
local NUM_BANKBAGSLOTS = _G.NUM_BANKBAGSLOTS;
local REAGENTBANK_CONTAINER = _G.REAGENTBANK_CONTAINER;

local FIRST_BANK_SLOT = NUM_BAG_SLOTS + 1;
local LAST_BANK_SLOT = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS;
-- for some reason there is no constant for bank bag container
local BANKBAG_CONTAINER = -4;
local FIRST_SLOT = BANKBAG_CONTAINER;
local LAST_SLOT = LAST_BANK_SLOT;

local flaggedBags = {};
local bagCache;

local function flagBag (index)
  flaggedBags[index] = true;
end

local function readBagSlot (bagContent, bagIndex, slotIndex)
  --[[ GetContainerItemID has to be used, as GetContainerItemInfo returns
         nil if data is not ready --]]
  local id = GetContainerItemID(bagIndex, slotIndex);

  if (not id) then return end

  local info = {GetContainerItemInfo(bagIndex, slotIndex)};
  local count = info[2];
  local link = info[7];

  bagContent:addItem(id, link, count);
end

local function updateBagCache (bagIndex)
  -- For some reason GetContainerNumSlots returns 0 for BANKBAG_CONTAINER
  local slotCount = bagIndex == BANKBAG_CONTAINER and NUM_BANKBAGSLOTS or
      GetContainerNumSlots(bagIndex);
  local bagContent = Storage:new();

  for slotIndex = 1, slotCount, 1 do
    readBagSlot(bagContent, bagIndex, slotIndex);
  end

  bagCache[bagIndex] = bagContent;
end

local function updateFlaggedBags ()
  for bagIndex in pairs(flaggedBags) do
    updateBagCache(bagIndex);
  end

  flaggedBags = {};
end

local function initInventory ()
  bagCache = {};
  flaggedBags = {};

  for x = FIRST_SLOT, LAST_SLOT, 1 do
    updateBagCache(x);
  end

  Items.updateCurrentInventory();
end

local function addEventListeners ()
  addon.on('BANKFRAME_OPENED', function ()
    updateBagCache(BANKBAG_CONTAINER);
    updateBagCache(BANK_CONTAINER);

    for x = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
      updateBagCache(x);
    end

    Items.updateCurrentInventory();
  end);

  addon.on({'BANKFRAME_CLOSED', 'PLAYER_ENTERING_WORLD'}, function ()
    bagCache[BANKBAG_CONTAINER] = nil;
    bagCache[BANK_CONTAINER] = nil;

    for x = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
      bagCache[x] = nil;
    end
  end);

  addon.on('BAG_UPDATE', flagBag);

  addon.on('PLAYERBANKSLOTS_CHANGED', function (slot)
    local maxSlot = GetContainerNumSlots(BANK_CONTAINER);

    if (slot <= maxSlot) then
      flagBag(BANK_CONTAINER);
    else
      flagBag(BANKBAG_CONTAINER);
    end
  end);

  addon.on('BAG_UPDATE_DELAYED', function ()
    updateFlaggedBags();
  end);

  if (addon.isClassic() == false) then
    addon.on('PLAYERREAGENTBANKSLOTS_CHANGED', function ()
      flagBag(REAGENTBANK_CONTAINER);
    end);
  end
end

addon.on('PLAYER_LOGIN', function ()
  initInventory();
  addEventListeners();
end);

Items.addStorage(function ()
  return bagCache;
end);
