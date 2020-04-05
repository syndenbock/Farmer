local addonName, addon = ...;

local StorageUtils = addon.StorageUtils;

local addItem = StorageUtils.addItem;

local Items = {};
local storageList = {};
local currentInventory = {};

addon.Items = Items;

local function getFirstKey (table)
  return next(table, nil);
end

local function readStorage (inventory, storage)
  for containerIndex, container in pairs(storage) do
    if (container ~= nil) then
      for itemId, itemInfo in pairs(container) do
        addItem(inventory, itemId, itemInfo.count, itemInfo.links);
      end
    end
  end
end

local function getCachedInventory (callback)
  local callbackList = {};
  local inventory = {};

  for storageIndex = 1, #storageList, 1 do
    local handler = storageList[storageIndex];
    local storage;

    if (type(handler) == 'function') then
      storage = handler();
    end

    if (type(storage) == 'function') then
      table.insert(callbackList, function (done)
        storage(function (storage)
          readStorage(inventory, storage);
          done();
        end);
      end);
    else
      readStorage(inventory, storage);
    end
  end

  addon:waitForCallbacks(callbackList, function ()
    callback(inventory);
  end);
end

function Items:addStorage (getter)
  table.insert(storageList, getter);
end

function Items:updateCurrentInventory ()
  getCachedInventory(function (inventory)
    currentInventory = inventory;
  end);
end

function Items:addItemToCurrentInventory (id, count, linkMap)
  addItem(currentInventory, id, count, linkMap);
end

function Items:addNewItem (id, count, link)
  addItem(currentInventory, id, count, link);
  addon:yell('NEW_ITEM', id, link, count);
end

function Items:checkInventory ()
  getCachedInventory(function (inventory)
    local new = {};

    for id, info in pairs(inventory) do
      if (currentInventory[id] == nil) then
        new[id] = {
          count = inventory[id].count,
          link = getFirstKey(inventory[id].links)
        };
      elseif (inventory[id].count > currentInventory[id].count) then
        local links = inventory[id].links;
        local currentLinks = currentInventory[id].links;
        local found = false;

        for link, value in pairs(links) do
          if (currentLinks[link] == nil) then
            found = true;
            new[id] = {
              count = inventory[id].count - currentInventory[id].count,
              link = link
            };
            break;
          end
        end

        if (found == false) then
          new[id] = {
            count = inventory[id].count - currentInventory[id].count,
            link = getFirstKey(links)
          };
        end
      end
    end

    for id, info in pairs(new) do
      addon:yell('NEW_ITEM', id, info.link, info.count);
    end

    currentInventory = inventory;
  end);
end
