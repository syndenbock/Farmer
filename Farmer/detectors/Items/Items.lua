local _, addon = ...;

addon.registerAvailableDetector('items');

local C_Item = _G.C_Item;
local IsItemDataCachedByID = C_Item.IsItemDataCachedByID;
local GetItemInfo = _G.C_Item.GetItemInfo;

local extractNormalizedItemString = addon.extractNormalizedItemString;
local fetchItemLink = addon.fetchItemLink;
local ImmutableMap = addon.import('Factory/ImmutableMap');

local Items = addon:extend('Items', {});
local storages = {};
local changesStorage = addon.import('Class/Storage'):new();

function Items.addStorage (storage)
  assert(storages[storage] == nil, 'storage was already added');
  storages[storage] = true;
end

local function readItemChanges (changes, id, itemInfo)
  --[[In theory, if an item gets moved to another bag while another item with
      the same id gets looted into the original bag of the item, this will
      cause the already owned item to be displayed instead of the new one.
      In reality, that case is extremely rare and the game will propably send
      two BAG_UPDATE_DELAYED events for that anyways, so we can use this to
      gain performance]]
  if (itemInfo.count ~= 0) then
    for link, count in pairs(itemInfo.links) do
      if (count ~= 0) then
        changes:addChange(id, extractNormalizedItemString(link) or link, count);
      end
    end
  end
end

local function readContainerChanges (changes, container)
  for id, itemInfo in pairs(container:getChanges()) do
    readItemChanges(changes, id, itemInfo);
  end

  container:clearChanges();
end

local function readStorage (storage)
  if (type(storage) == 'table') then
    return storage;
  else
    return storage();
  end
end

local function readStorageChanges (changes, storage)
  for _, container in pairs(storage) do
    readContainerChanges(changes, container);
  end
end

local function getInventoryChanges ()
  for storage in pairs(storages) do
    readStorageChanges(changesStorage, readStorage(storage));
  end

  return changesStorage:getChanges();
end

local function clearInventoryChanges ()
  changesStorage:clearChanges();
end

local function packItemInfo (itemId, itemLink)
  local info = {GetItemInfo(itemLink)};

  return {
    id = itemId,
    name = info[1],
    link = info[2],
    rarity = info[3],
    level = info[4],
    minLevel = info[5],
    type = info[6],
    subType = info[7],
    stackSize = info[8],
    equipLocation = info[9],
    texture = info[10],
    sellPrice = info[11],
    classId = info[12],
    subClassId = info[13],
    bindType = info[14],
    expansionId = info[15],
    itemSetId = info[16],
    isCraftingReagent = info[17],
  };
end

local function yellItem (itemId, itemLink, itemCount)
  addon.yell('ITEM_CHANGED', ImmutableMap(packItemInfo(itemId, itemLink)),
      itemCount);
end

local function broadCastItem (id, link, count)
  if (IsItemDataCachedByID(id)) then
    yellItem(id, link, count);
  else
    fetchItemLink(id, link, yellItem, count);
  end
end

local function broadCastItemInfo (id, info)
  for link, count in pairs(info.links) do
    if (count ~= 0) then
      broadCastItem(id, link, count);
    end
  end
end

local function checkStorageChanges ()
  for id, info in pairs(getInventoryChanges()) do
    if (info.count ~= 0) then
      broadCastItemInfo(id, info);
    end
  end

  clearInventoryChanges();
end

addon.on('BAG_UPDATE_DELAYED', checkStorageChanges);

--##############################################################################
-- testing
--##############################################################################

local function testItem (id, count)
  local _, link = GetItemInfo(id);

  if (link) then
    broadCastItem(id, link, count);
  else
    addon.printAddonMessage('No data for item id', id);
  end
end

local function testPredefinedItems ()
  local testItems = {
    2447, -- Peacebloom
    4496, -- Small Brown Pouch
    6975, -- Whirlwind Axe
    4322, -- Enchanter's Cowl
    13521, -- Recipe: Flask of Supreme Power
    156631, -- Silas' Sphere of Transmutation
    71636, -- Monstrous Egg
    168207, -- plundered anima cell
    172045 -- Tenebrous Crown Roast Aspic
  };

  for _, item in ipairs(testItems) do
    testItem(item, 1);
    -- testItem(item, 4);
  end
end

addon.import('tests').items = function (id, count)
  if (id) then
    testItem(tonumber(id), count or 1);
  else
    testPredefinedItems();
  end
end
