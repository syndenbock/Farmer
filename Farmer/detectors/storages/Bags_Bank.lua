local addonName, addon = ...;

local Items = addon.Items;
local addItem = addon.StorageUtils.addItem;

local Item = _G.Item;
local C_Item = _G.C_Item;
local IsItemDataCachedByID = C_Item.IsItemDataCachedByID;
local GetContainerNumSlots = _G.GetContainerNumSlots;
local GetContainerItemID = _G.GetContainerItemID;
local GetContainerItemInfo = _G.GetContainerItemInfo;
local BANK_CONTAINER = _G.BANK_CONTAINER;
local BACKPACK_CONTAINER = _G.BACKPACK_CONTAINER;
local REAGENTBANK_CONTAINER = _G.REAGENTBANK_CONTAINER;
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS;
local NUM_BANKBAGSLOTS = _G.NUM_BANKBAGSLOTS;

local FIRST_BAG_SLOT = BACKPACK_CONTAINER;
local LAST_BAG_SLOT = BACKPACK_CONTAINER + NUM_BAG_SLOTS;

local FIRST_BANK_SLOT = NUM_BAG_SLOTS + 1;
local LAST_BANK_SLOT = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS;
-- for some reason there is no constant for bank bag container
local BANKBAG_CONTAINER = -4;
local FIRST_SLOT = BANKBAG_CONTAINER;
local LAST_SLOT = LAST_BANK_SLOT;

local flaggedBags = {};
local bagCache = {};

local function flagBag (index)
  flaggedBags[index] = true;
end

local function updateBagCache (bagIndex, callback)
  -- For some reason GetContainerNumSlots returns 0 for BANKBAG_CONTAINER
  local slotCount = bagIndex == BANKBAG_CONTAINER and NUM_BANKBAGSLOTS or
      GetContainerNumSlots(bagIndex);
  local bagContent = {};
  local callbackList = {};

  for slotIndex = 1, slotCount, 1 do
    --[[ GetContainerItemID has to be used, as GetContainerItemInfo returns
         nil if data is not ready --]]
    local id = GetContainerItemID(bagIndex, slotIndex);

    if (id ~= nil) then
      local info = {GetContainerItemInfo(bagIndex, slotIndex)};
      local count = info[2];

      if (IsItemDataCachedByID(id)) then
        local link = info[7];

        addItem(bagContent, id, count, link);
      else
        --[[ Info may not be available yet. We only use asynchronous callbacks
             in that case because they have quite a bit of overhead. --]]
        --[[ Own implementation is a bit faster, but I don't want to risk
             bugs in code that is only very rarely executed --]]
        table.insert(callbackList, function (callback)
          local item = Item:CreateFromBagAndSlot(bagIndex, slotIndex);

          item:ContinueOnItemLoad(function ()
            addItem(bagContent, id, count, item:GetItemLink());
            callback();
          end);
        end);
      end
    end
  end

  addon:waitForCallbacks(callbackList, function ()
    bagCache[bagIndex] = bagContent;
    callback();
  end);
end

local function updateFlaggedBags (callback)
  local callbackList = {};

  for bagIndex in pairs(flaggedBags) do
    table.insert(callbackList, addon:bindParams(updateBagCache, bagIndex));
  end

  addon:waitForCallbacks(callbackList, function ()
    flaggedBags = {};
    callback();
  end);
end

local function readInventory (callback)
  local callbackList = {};

  bagCache = {};
  flaggedBags = {};


  for x = FIRST_SLOT, LAST_SLOT, 1 do
    table.insert(callbackList, addon:bindParams(updateBagCache, x));
  end

  addon:waitForCallbacks(callbackList, function ()
    flaggedBags = {};
    callback();
  end);
end

local function addEventHooks ()
  addon:on('BANKFRAME_OPENED', function ()
    local callbackList = {};

    table.insert(callbackList, addon:bindParams(updateBagCache, BANKBAG_CONTAINER));
    table.insert(callbackList, addon:bindParams(updateBagCache, BANK_CONTAINER));

    for x = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
      table.insert(callbackList, addon:bindParams(updateBagCache, x));
    end

    addon:waitForCallbacks(callbackList, function ()
      Items:updateCurrentInventory();
    end);
  end);

  addon:on('BANKFRAME_CLOSED', function ()
    bagCache[BANKBAG_CONTAINER] = nil;
    bagCache[BANK_CONTAINER] = nil;

    for x = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
      bagCache[x] = nil;
    end
  end);

  addon:on('BAG_UPDATE', function (bagIndex)
    flagBag(bagIndex);
  end);

  addon:on('PLAYERBANKSLOTS_CHANGED', function ()
    flagBag(BANKBAG_CONTAINER);
    flagBag(BANK_CONTAINER);
  end);

  if (addon:isClassic() == false) then
    addon:on('PLAYERREAGENTBANKSLOTS_CHANGED', function ()
      flagBag(REAGENTBANK_CONTAINER);
    end);
  end

  addon:on('BAG_UPDATE_DELAYED', function ()
    updateFlaggedBags(function ()
      Items:checkInventory();
    end);
  end);
end

addon:on('PLAYER_LOGIN', function ()
  readInventory(function ()
    addEventHooks();
    Items:updateCurrentInventory();
  end);
end);

Items:addStorage(function ()
  return bagCache;
end);
