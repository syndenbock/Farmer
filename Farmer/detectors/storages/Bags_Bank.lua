local addonName, addon = ...;

local Items = addon.Items;
local addItem = addon.StorageUtils.addItem;

local BANK_CONTAINER = _G.BANK_CONTAINER;
local REAGENTBANK_CONTAINER = _G.REAGENTBANK_CONTAINER;
local KEYRING_CONTAINER = _G.KEYRING_CONTAINER;
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS;
local NUM_BANKBAGSLOTS = _G.NUM_BANKBAGSLOTS;

local FIRST_SLOT = REAGENTBANK_CONTAINER ~= nil and REAGENTBANK_CONTAINER or KEYRING_CONTAINER;
local LAST_SLOT = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS;

local flaggedBags = {};
local bagCache = {};
local awaitedItems = {};
local bankIsOpen = false;

local function flagBag (index)
  flaggedBags[index] = true;
end

local function awaitItem (id, bagIndex, slotIndex)
  awaitedItems[id] = awaitedItems[id] or {};
  awaitedItems[id][bagIndex] = awaitedItems[id][bagIndex] or {};

  if (awaitedItems[id][bagIndex][slotIndex] == nil) then
    -- print('awaiting item:', id);
    awaitedItems[id][bagIndex][slotIndex] = true;
  end
end

local function updateBagCache (bagIndex)
  local bagContent = {};
  local slotCount = GetContainerNumSlots(bagIndex);

  if (awaitedItems ~= nil) then
    awaitedItems[bagIndex] = nil;
  end

  for slotIndex = 1, slotCount, 1 do
    --[[ GetContainerItemID has to be used, as GetContainerItemInfo returns
         nil if data is not ready --]]
    local id = GetContainerItemID(bagIndex, slotIndex);

    if (id ~= nil) then
      --[[ Manually calculating the bag count is way faster than using
           GetItemCount --]]
      local name, count, _, _, _, _, link, _, _, _id = GetContainerItemInfo(bagIndex, slotIndex);

      --[[ On login, information is not available yet but the game will not
           fire GET_ITEM_INFO_RECEIVED. But there will be a ton of BAG_UPDATE
           events which would cause the entire bags to be displayed. Therefor
           items are added even without information if awaitedItems has not
           been initialized yet which is done after reading the inventory on
           login --]]
      if (_id == nil) then
        -- print('no information for bag item available');
        awaitItem(id, bagIndex, slotIndex);
      else
        addItem(bagContent, id, count, link);
      end
    end
  end

  bagCache[bagIndex] = bagContent;
end

local function updateFlaggedBags ()
  for bagIndex in pairs(flaggedBags) do
    updateBagCache(bagIndex);
  end

  flaggedBags = {};
end

local function checkInventory ()
  updateFlaggedBags();
  Items:checkInventory();
end

local function checkAwaitedItems (itemId)
  local bagMap = awaitedItems[itemId];

  if (bagMap == nil) then return end

  for bagIndex, slotMap in pairs(bagMap) do
    local bagContent = bagCache[bagIndex];

    for slotIndex in pairs(slotMap) do
      local _, count, _, _, _, _, link, _, _, id = GetContainerItemInfo(bagIndex, slotIndex);

      addItem(bagContent, id, count, link);
      Items:addNewItem(id, count, link);
      --print('received awaited item:', itemId);
    end
  end
end

local function readInventory ()
  bagCache = {};
  flaggedBags = {};

  for i = FIRST_SLOT, LAST_SLOT, 1 do
    updateBagCache(i);
  end
end

local function addEventHooks ()
  addon:on('BANKFRAME_OPENED', function ()
    bankIsOpen = true;
    readInventory();
    Items:updateCurrentInventory();
  end);

  addon:on('BANKFRAME_CLOSED', function ()
    bankIsOpen = false;
  end);

  --[[ BANKFRAME_CLOSED fires multiple times and bank slots are still available
       on the event frame, so we funnel to execute only once one second later --]]
  addon:funnel('BANKFRAME_CLOSED', 1, function ()
    if (bankIsOpen == true) then return end

    readInventory();
    Items:updateCurrentInventory();
  end);

  addon:on('BAG_UPDATE', function (bagIndex)
    flagBag(bagIndex);
  end);

  addon:on('PLAYERBANKSLOTS_CHANGED', function ()
    flagBag(BANK_CONTAINER);
  end);

  if (addon:isClassic() == false) then
    addon:on('PLAYERREAGENTBANKSLOTS_CHANGED', function ()
      flagBag(REAGENTBANK_CONTAINER);
    end);
  end

  addon:on('BAG_UPDATE_DELAYED', checkInventory);
  addon:on('GET_ITEM_INFO_RECEIVED', checkAwaitedItems);
end

local function initInventory ()
  readInventory();

  if (next(awaitedItems) == nil) then
    addon:off('BAG_UPDATE_DELAYED', initInventory);
    Items:updateCurrentInventory();
    addEventHooks();
  else
    awaitedItems = {};
  end
end

addon:on('BAG_UPDATE_DELAYED', initInventory);

Items:addStorage(function ()
  return bagCache;
end);
