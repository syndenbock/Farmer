local _, addon = ...;

local tinsert = _G.tinsert;
local C_Item = _G.C_Item;
local IsItemDataCachedByID = C_Item.IsItemDataCachedByID;
local DoesItemExistByID = C_Item.DoesItemExistByID;
local GetItemInfo = _G.GetItemInfo;
local Item = _G.Item;

local StorageUtils = addon.StorageUtils;
local addItem = StorageUtils.addItem;

local Items = {};
local storageList = {};
local currentInventory = {};

addon.Items = Items;

local function getFirstKey (table)
  -- keep this so only the first return value is returned
  local key = next(table);

  return key;
end

local function readStorage (inventory, storage)
  if (not storage) then return end

  for _, container in pairs(storage) do
    if (container) then
      for itemId, itemInfo in pairs(container) do
        addItem(inventory, itemId, itemInfo.count, itemInfo.links);
      end
    end
  end
end

local function getCachedInventory ()
  local inventory = {};

  for storageIndex = 1, #storageList, 1 do
    local storage = storageList[storageIndex];

    if (type(storage) == 'function') then
      storage = storage();
    end

    readStorage(inventory, storage);
  end

  return inventory;
end

function Items:addStorage (storage)
  tinsert(storageList, storage);
end

function Items:updateCurrentInventory ()
  currentInventory = getCachedInventory();
end

function Items:addItemToCurrentInventory (id, count, linkMap)
  addItem(currentInventory, id, count, linkMap);
end

function Items:addNewItem (id, count, link)
  addItem(currentInventory, id, count, link);
  addon:yell('NEW_ITEM', id, link, count);
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
  for id, linkMap in pairs(new) do
    for link, count in pairs(linkMap) do
      if (IsItemDataCachedByID(id)) then
        addon:yell('NEW_ITEM', id, link, count);
      else
        fetchItem(id, link, count);
      end
    end
  end
end

local function addNewItem (new, id, link, count)
  local data = new[id] or {};

  data[link] = (data[link] or 0) + count;
  new[id] = data;
end

local function checkInventory ()
  local inventory = getCachedInventory();

  local new = {};

  for id, data in pairs(inventory) do
    local currentData = currentInventory[id];
    local links = data.links;

    if (not currentData) then
      for link, count in pairs(links) do
        addNewItem(new, id, link, count);
      end
    elseif (data.count > currentData.count) then
      local currentLinks = currentData.links;
      local found = false;

      for link, count in pairs(links) do
        local currentCount = currentLinks[link] or 0;

        if (count > currentCount) then
          found = true;
          addNewItem(new, id, link, count - currentCount);
        end
      end

      if (not found) then
        addNewItem(new, id, getFirstKey(links), data.count - currentData.count);
      end
    end
  end

  currentInventory = inventory;
  broadcastItems(new);
end

--[[ Funneling the check so it executes on the next frame after
     BAG_UPDATE_DELAYED. This allows storages to update first to avoid race
     conditions ]]
addon:funnel('BAG_UPDATE_DELAYED', checkInventory);
