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

local function getCachedInventory ()
  local inventory = {};

  for storageIndex = 1, #storageList, 1 do
    local storage = storageList[storageIndex]();

    for containerIndex, container in pairs(storage) do
      if (container ~= nil) then
        for itemId, itemInfo in pairs(container) do
          addItem(inventory, itemId, itemInfo.count, itemInfo.links);
        end
      end
    end
  end

  return inventory;
end

function Items:addStorage (getter)
  table.insert(storageList, getter);
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

function Items:checkInventory ()
  local inventory = getCachedInventory();

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
end
