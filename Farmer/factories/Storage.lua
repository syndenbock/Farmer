local _, addon = ...;

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

function Storage:getItems ()
  return self.storage;
end

function Storage:createItem (itemLink, itemId, itemCount)
  self.storage[itemLink] = {
    count = itemCount,
    id = itemId,
  };
end

function Storage:updateItem (itemLink, itemCount)
  self.storage[itemLink].count = self.storage[itemLink].count + itemCount;
end

function Storage:addItem (itemId, itemLink, itemCount)
  -- This is the main inventory handling function and gets called a lot.
  -- Therefor, performance has priority over code shortage.
  if (self.normalized) then
    itemLink = addon.extractNormalizedItemString(itemLink) or itemLink;
  end

  if (not self.storage[itemLink]) then
    self:createItem(itemLink, itemId, itemCount);
  else
    self:updateItem(itemLink, itemCount);
  end
end

function Storage:addStorage (updateStorage)
  for itemLink, itemInfo in pairs(updateStorage:getItems()) do
    self:addItem(itemInfo.id, itemLink, itemInfo.count);
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

  for itemLink, itemInfo in pairs(compareStorage.storage) do
    local thisItemInfo = thisStorage[itemLink];

    if (not thisItemInfo) then
      new:addItem(itemLink, itemInfo.id, itemInfo.count);
    else
      local difference = itemInfo.count - thisItemInfo.count;

      if (difference > 0) then
        new:addItem(itemLink, itemInfo.id, difference);
      end
    end
  end

  return new;
end
