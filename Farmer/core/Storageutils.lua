local addonName, addon = ...;

local strmatch = _G.strmatch;

local utils = {};

addon.StorageUtils = utils;

local Storage = {}

addon.Storage = Storage

Storage.__index = Storage

function Storage:create()
  local this = {}

  setmetatable(this, Storage)
  this.storage = {}

  return this
end

function Storage:addItem (itemId, itemLink, itemCount)
  -- This is the main inventory handling function and gets called a lot.
  -- Therefor, performance has priority over code shortage.
  local storage = self.storage;
  local itemInfo = storage[itemId];

  if (not itemInfo) then
    storage[itemId] = {
      count = itemCount,
      links = {
        [itemLink] = itemCount,
      },
    };
  else
    local links = itemInfo.links;

    itemInfo.count = itemInfo.count + itemCount;
    links[itemLink] = (links[itemLink] or 0) + itemCount;
  end
end

function utils.normalizeItemLink (itemLink)
  local itemString = strmatch(itemLink, "item[%-?%d:]+")

  if not itemString then return itemLink end

  local newLink = '|cffffffff' .. itemString .. '|hh|r'

  return newLink
end
