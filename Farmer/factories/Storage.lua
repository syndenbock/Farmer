local addonName, addon = ...;

local strmatch = _G.strmatch;
local Storage = {}

addon.Storage = Storage

Storage.__index = Storage

function Storage:create()
  local this = {}

  setmetatable(this, Storage)
  this.storage = {}

  return this
end

function Storage:normalizeAndAddItem (itemId, itemLink, itemCount)
  itemLink = Storage.normalizeItemLink(itemLink);
  self:addItem(itemId, itemLink, itemCount);
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

  if (not itemInfo) then
    self:createItem(itemId, itemLink, itemCount);
  else
    self:updateItem(itemId, itemLink, itemCount);
  end
end

function Storage:update (updateStorage, normalize)
  if (not updateStorage) then return end

  for _, container in pairs(updateStorage) do
    if (container) then
      for itemId, itemInfo in pairs(container.storage) do
        for itemLink, itemCount in pairs(itemInfo.links) do
          if (normalze) then
            self:normalizeAndAddItem(itemId, itemLink, itemCount);
          else
            self:addItem(itemId, itemLink, itemCount);
          end
        end
      end
    end
  end
end

function Storage:compare (compareStorage)
  local thisStorage = self.storage;
  local new = Storage:create();

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

function Storage.normalizeItemLink (itemLink)
  local itemString = strmatch(itemLink, "item[%-?%d:]+")

  if not itemString then return itemLink end

  local newLink = '|cffffffff' .. itemString .. '|hh|r'

  return newLink
end
