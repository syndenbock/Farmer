local addonName, addon = ...;

local strmatch = _G.strmatch;

local utils = {};

addon.StorageUtils = utils;

function utils.normalizeItemLink (itemLink)
  local itemString = strmatch(itemLink, "item[%-?%d:]+")

  if not itemString then return itemLink end

  local newLink = '|cffffffff' .. itemString .. '|hh|r'

  return newLink
end

local Storage = {}

addon.Storage = Storage

Storage.__index = Storage

function Storage:create()
  local this = {}

  setmetatable(this, Storage)
  this.storage = {}

  return this
end

function Storage:addItem (itemLink, count)
  local storage = self.storage

  storage[itemLink] = (storage[itemLink] or 0) + count
end
