local _, addon = ...;

if (addon.isClassic()) then return end

local Storage = addon.Factory.Storage;
local Items = addon.Items;

local IsVoidStorageReady = _G.IsVoidStorageReady;
local GetVoidItemHyperlinkString = _G.GetVoidItemHyperlinkString;
local GetVoidItemInfo = _G.GetVoidItemInfo;

local NUM_VOIDSTORAGE_TABS = 2;
local NUM_VOIDSTORAGE_SLOTS = 80;
local storageTabs = nil;

local function initStorageTabs ()
  storageTabs = {};

  for tabIndex = 1, NUM_VOIDSTORAGE_TABS, 1 do
    storageTabs[tabIndex] = Storage:new();
  end
end

local function getCombinedIndex (tabIndex, slotIndex)
  return (tabIndex - 1) * NUM_VOIDSTORAGE_SLOTS + slotIndex;
end

local function readVoidStorageSlot (storage, tabIndex, slotIndex)
  local id = GetVoidItemInfo(tabIndex, slotIndex);

  if (not id) then
    storage:clearSlot(slotIndex);
    return;
  end

  --[[ For some reason, one function requires tabIndex and slotIndex
       and a related function requires slotIndex as if there was only
       one tab. Blizzard code at its best once again. ]]
  local combinedIndex = getCombinedIndex(tabIndex, slotIndex);
  local link = GetVoidItemHyperlinkString(combinedIndex);

  storage:setSlot(slotIndex, id, link, 1);
end

local function readVoidStorageTab (tabIndex)
  local storage = storageTabs[tabIndex];

  for slotIndex = 1, NUM_VOIDSTORAGE_SLOTS, 1 do
    readVoidStorageSlot(storage, tabIndex, slotIndex);
  end
end

local function readVoidStorage ()
  for tabIndex = 1, NUM_VOIDSTORAGE_TABS, 1 do
    readVoidStorageTab(tabIndex);
  end
end

local function clearVoidStorageChanges ()
  for _, storage in pairs(storageTabs) do
    storage:clearChanges();
  end
end

local function initVoidStorage ()
  initStorageTabs();
  readVoidStorage();
  clearVoidStorageChanges();
end

addon.on('VOID_STORAGE_OPEN', initVoidStorage);
addon.on({'VOID_STORAGE_CONTENTS_UPDATE', 'VOID_TRANSFER_DONE'},
    readVoidStorage);

Items.addStorage(function ()
  return storageTabs;
end);
