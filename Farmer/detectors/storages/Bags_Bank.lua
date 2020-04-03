local addonName, addon = ...;

local Items = addon.Items;
local addItem = addon.StorageUtils.addItem;

local GetContainerNumSlots = _G.GetContainerNumSlots;
local GetContainerItemID = _G.GetContainerItemID;
local GetContainerItemInfo = _G.GetContainerItemInfo;
local BANK_CONTAINER = _G.BANK_CONTAINER;
local REAGENTBANK_CONTAINER = _G.REAGENTBANK_CONTAINER;
local KEYRING_CONTAINER = _G.KEYRING_CONTAINER;
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS;
local NUM_BANKBAGSLOTS = _G.NUM_BANKBAGSLOTS;

local FIRST_BANK_SLOT = NUM_BAG_SLOTS + 1;
local LAST_BANK_SLOT = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS;
local FIRST_SLOT = REAGENTBANK_CONTAINER ~= nil and REAGENTBANK_CONTAINER or KEYRING_CONTAINER;
local LAST_SLOT = LAST_BANK_SLOT;

local flaggedBags = {};
local bagCache = {};

local function flagBag (index)
  flaggedBags[index] = true;
end

local function updateBagCache (bagIndex)
  local bagContent = {};
  local slotCount = GetContainerNumSlots(bagIndex);
  local hasEmpty = false;

  for slotIndex = 1, slotCount, 1 do
    --[[ GetContainerItemID has to be used, as GetContainerItemInfo returns
         nil if data is not ready --]]
    local id = GetContainerItemID(bagIndex, slotIndex);

    if (id ~= nil) then
      --[[ Manually calculating the bag count is way faster than using
           GetItemCount --]]
      local name, count, _, _, _, _, link, _, _, _id = GetContainerItemInfo(bagIndex, slotIndex);

      --[[ On login or on generated items like Mage cookies info may not be
           available yet. When it is available, another "BAG_UPDATE_DELAYED"
           event is fired, so luckily we don't need to handle asynchroneously ]]
      if (_id == nil) then
        --[[ If this for some reason ever stops working, this would be the way
             to receive the info ]]
        --local item = Item:CreateFromBagAndSlot(bagIndex, slotIndex);
        --
        --item:ContinueOnItemLoad(function ()
        --  addItem(bagContent, id, count, link);
        --end);

        hasEmpty = true;
      else
        addItem(bagContent, id, count, link);
      end
    end
  end

  bagCache[bagIndex] = bagContent;

  return hasEmpty;
end

local function updateFlaggedBags ()
  local hasEmpty = false;

  for bagIndex in pairs(flaggedBags) do
    hasEmpty = updateBagCache(bagIndex) or hasEmpty;
  end

  flaggedBags = {};

  return hasEmpty;
end

local function checkInventory ()
  updateFlaggedBags();
  Items:checkInventory();
end

local function readInventory ()
  local hasEmpty = false;

  bagCache = {};
  flaggedBags = {};

  for i = FIRST_SLOT, LAST_SLOT, 1 do
    hasEmpty = updateBagCache(i) or hasEmpty;
  end

  return hasEmpty;
end

local function addEventHooks ()
  addon:on('BANKFRAME_OPENED', function ()
    updateBagCache(BANK_CONTAINER);

    for x = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
      updateBagCache(x);
    end

    Items:updateCurrentInventory();
  end);

  addon:on('BANKFRAME_CLOSED', function ()
    bagCache[BANK_CONTAINER] = nil;

    for x = FIRST_BANK_SLOT, LAST_BANK_SLOT, 1 do
      bagCache[x] = nil;
    end
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
end

local function initInventory ()
  local hasEmpty = readInventory();

  --[[ the game needs a few iterations until all items are loaded ]]
  if (hasEmpty == false) then
    addon:off('BAG_UPDATE_DELAYED', initInventory);
    Items:updateCurrentInventory();
    addEventHooks();
  end
end

addon:on('BAG_UPDATE_DELAYED', initInventory);

Items:addStorage(function ()
  return bagCache;
end);
