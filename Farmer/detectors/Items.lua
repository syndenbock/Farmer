local addonName, addon = ...;

local tinsert = _G.tinsert;
local C_Item = _G.C_Item;
local IsItemDataCachedByID = C_Item.IsItemDataCachedByID;
local DoesItemExistByID = C_Item.DoesItemExistByID;
local GetItemInfo = _G.GetItemInfo;
local Item = _G.Item;

local Storage = addon.Factory.Storage;
local ImmutableMap = addon.Factory.ImmutableMap;

local Items = {};
local storageList = {};

addon.Items = Items;

function Items.addStorage (storage)
  tinsert(storageList, storage);
end

local function addContainerChanges (changes, container)
  local containerChanges = container:getChanges();

  container:clearChanges();

  for _, info in pairs(containerChanges) do
    changes:addChange(info.id, info.link, info.count);
  end
end

local function addMultipleChanges (changes, storage)
  for _, container in pairs(storage) do
    addContainerChanges(changes, container);
  end
end

local function addStorageChanges (changes, storage)
  if (type(storage) == 'function') then
    storage = storage();
  end

  addMultipleChanges(changes, storage);
end

local function getInventoryChanges ()
  local changes = Storage:new();

  for _, storage in ipairs(storageList) do
    addStorageChanges(changes, storage);
  end

  return changes:getChanges();
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
  addon.yell('NEW_ITEM', ImmutableMap(packItemInfo(itemId, itemLink)),
      itemCount);
end

local function fetchItem (id, link, count)
  --[[ Apparently you can actually have non-existent items in your bags ]]
  if (not DoesItemExistByID(id)) then
    return yellItem(id, link, count);
  end

  local item = Item:CreateFromItemID(id);

  item:ContinueOnItemLoad(function()
    --[[ The original link does contain enough information for a call to
         GetItemInfo which then returns a complete itemLink ]]
    --[[ Some items like mythic keystones and caged pets don't get a new link
         by GetItemInfo ]]
    link = select(2, GetItemInfo(link)) or link;

    yellItem(id, link, count);
  end);
end

local function broadCastItem (itemInfo)
  if (IsItemDataCachedByID(itemInfo.id)) then
    yellItem(itemInfo.id, itemInfo.link, itemInfo.count);
  else
    fetchItem(itemInfo.id, itemInfo.link, itemInfo.count);
  end
end

local function broadcastItems (items)
  for _, itemInfo in pairs(items) do
    broadCastItem(itemInfo);
  end
end

local function checkInventory ()
  broadcastItems(getInventoryChanges());
end

--[[ Funneling the check so it executes on the next frame after
     BAG_UPDATE_DELAYED. This allows storages to update first to avoid race
     conditions ]]
addon.funnel('BAG_UPDATE_DELAYED', checkInventory);

--##############################################################################
-- testing
--##############################################################################

local function testItem (id, count)
  local _, link = GetItemInfo(id);

  if (link) then
    yellItem(id, link, count);
  else
    print(addonName .. ': no data for item id', id);
  end
end

local function testPredefinedItems ()
  local testItems = {
    2447, -- Peacebloom
    4496, -- Small Brown Pouch
    6975, -- Whirlwind Axe
    4322, -- Enchanter's Cowl
    13521, -- Recipe: Flask of Supreme Power
    156631 -- Silas' Sphere of Transmutation
  };

  for _, item in ipairs(testItems) do
    testItem(item, 1);
    testItem(item, 4);
  end
end

addon.share('tests').items = function (id, count)
  if (id) then
    testItem(tonumber(id), count or 1);
  else
    testPredefinedItems();
  end
end
