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

function Storage:addItem (itemLink, itemCount)
  -- This is the main inventory handling function and gets called a lot.
  -- Therefor, performance has priority over code shortage.
  if (self.normalized) then
    itemLink = addon.extractNormalizedItemString(itemLink) or itemLink;
  end

  self.storage[itemLink] = (self.storage[itemLink] or 0) + itemCount;
end

function Storage:addStorage (updateStorage)
  for itemLink, itemCount in pairs(updateStorage:getItems()) do
    self:addItem(itemLink, itemCount);
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

  for itemLink, itemCount in pairs(compareStorage.storage) do
    local difference = itemCount - (thisStorage[itemLink] or 0);

    if (difference > 0) then
      new:addItem(itemLink, difference);
    end
  end

  return new;
end
