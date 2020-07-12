local _, addon = ...;

local tinsert = _G.tinsert;
local min = _G.min;
local C_Item = _G.C_Item;
local IsItemDataCachedByID = C_Item.IsItemDataCachedByID;
local DoesItemExistByID = C_Item.DoesItemExistByID;
local GetItemInfo = _G.GetItemInfo;
local Item = _G.Item;

local Storage = addon.Storage;

local Items = {};
local storageList = {};
local currentInventory = {};

addon.Items = Items;

local function getCachedInventory ()
  local inventory = Storage:create();

  for storageIndex = 1, #storageList, 1 do
    local storage = storageList[storageIndex];

    if (type(storage) == 'function') then
      storage = storage();
    end

    inventory:update(storage, true);
  end

  return inventory;
end

function Items:addStorage (storage)
  tinsert(storageList, storage);
end

function Items:updateCurrentInventory ()
  currentInventory = getCachedInventory();
end

function Items:addItemToCurrentInventory (id, link, count)
  currentInventory:addItem(id, link, count);
end

local function fetchItem (id, link, count)
  --[[ Apparently you can actually have non-existent items in your bags ]]
  if (not DoesItemExistByID(id)) then
    addon:yell('NEW_ITEM', id, link, count);
    return;
  end

  local item = Item:CreateFromItemID(id);

  item:ContinueOnItemLoad(function()
    --[[ The original link does contain enough information for a call to
         GetItemInfo which then returns a complete itemLink ]]
    --[[ Some items like mythic keystones and caged pets don't get a new link
         by GetItemInfo ]]
    link = select(2, GetItemInfo(link)) or link;

    addon:yell('NEW_ITEM', id, link, count);
  end);
end

local function broadcastItems (new)
  for itemId, itemInfo in pairs(new) do
    for itemLink, itemCount in pairs(itemInfo.links) do
      if (IsItemDataCachedByID(itemId)) then
        addon:yell('NEW_ITEM', itemId, itemLink, itemCount);
      else
        fetchItem(itemId, itemLink, itemCount);
      end
    end
  end
end

local function checkInventory ()
  local inventory = getCachedInventory();
  local newItems = currentInventory:compare(inventory);

  currentInventory = inventory;
  broadcastItems(newItems.storage);
end

--[[ Funneling the check so it executes on the next frame after
     BAG_UPDATE_DELAYED. This allows storages to update first to avoid race
     conditions ]]
addon:funnel('BAG_UPDATE_DELAYED', checkInventory);
