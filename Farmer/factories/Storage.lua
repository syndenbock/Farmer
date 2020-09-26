local _, addon = ...;

local strmatch = _G.strmatch;

local Factory = addon.share('Factory');

local Storage = {};

Factory.Storage = Storage;

Storage.__index = Storage;

function Storage:new (options)
  local this = {};

  setmetatable(this, Storage);

  if (options) then
    this.normalized = options.normalized;
  end

  this.storage = {};

  return this;
end

function Storage:createItem (itemId, itemLink, itemCount)
  self.storage[itemId] = {
    count = itemCount,
    links = {
      [itemLink] = itemCount,
    },
  };
end

function Storage:updateItem (itemId, itemLink, itemCount)
  local itemInfo = self.storage[itemId];
  local links = itemInfo.links;

  itemInfo.count = itemInfo.count + itemCount;
  links[itemLink] = (links[itemLink] or 0) + itemCount;
end

function Storage:addItem (itemId, itemLink, itemCount)
  -- This is the main inventory handling function and gets called a lot.
  -- Therefor, performance has priority over code shortage.
  local itemInfo = self.storage[itemId];

  if (self.normalized) then
    itemLink = addon.extractItemString(itemLink);
  end

  if (not itemInfo) then
    self:createItem(itemId, itemLink, itemCount);
  else
    self:updateItem(itemId, itemLink, itemCount);
  end
end

function Storage:addItemInfo (itemId, itemInfo)
  for itemLink, itemCount in pairs(itemInfo.links) do
    self:addItem(itemId, itemLink, itemCount);
  end
end

function Storage:addStorage (updateStorage)
  for itemId, itemInfo in pairs(updateStorage.storage) do
    self:addItemInfo(itemId, itemInfo);
  end
end

function Storage:addMultipleStorages (storageMap)
  for _, storage in pairs(storageMap) do
    self:addStorage(storage);
  end
end

function Storage:compare (compareStorage)
  local thisStorage = self.storage;
  local new = Storage:new();

  for itemId, itemInfo in pairs(compareStorage.storage) do
    local thisItemInfo = thisStorage[itemId];

    if (not thisItemInfo) then
      for itemLink, itemCount in pairs(itemInfo.links) do
        new:addItem(itemId, itemLink, itemCount);
      end
    elseif (itemInfo.count > thisItemInfo.count) then
      local thisItemLinks = thisItemInfo.links;

      for itemLink, itemCount in pairs(itemInfo.links) do
        local thisItemCount = thisItemLinks[itemLink] or 0;

        if (itemCount > thisItemCount) then
          new:addItem(itemId, itemLink, itemCount - thisItemCount);
        end
      end
    end
  end

  return new;
end
