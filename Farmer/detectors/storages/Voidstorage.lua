local _, addon = ...;

if (_G.GetVoidItemInfo == nil) then return end

local Storage = addon.Class.Storage;

local GetVoidItemHyperlinkString = _G.GetVoidItemHyperlinkString;
local GetVoidItemInfo = _G.GetVoidItemInfo;

local NUM_VOIDSTORAGE_TABS = 2;
local NUM_VOIDSTORAGE_SLOTS = 80;
local storageTabs = {};

local function initStorageTabs ()
  for tabIndex = 1, NUM_VOIDSTORAGE_TABS, 1 do
    storageTabs[tabIndex] = Storage:new();
  end
end

local function getCombinedIndex (tabIndex, slotIndex)
  return (tabIndex - 1) * NUM_VOIDSTORAGE_SLOTS + slotIndex;
end

local function readVoidStorageSlot (storage, tabIndex, slotIndex)
  local id = GetVoidItemInfo(tabIndex, slotIndex);

  if (id) then
    --[[ For some reason, one function requires tabIndex and slotIndex
         and a related function requires slotIndex as if there was only
         one tab. Blizzard code at its best once again. ]]
    local combinedIndex = getCombinedIndex(tabIndex, slotIndex);
    local link = GetVoidItemHyperlinkString(combinedIndex);

    storage:setSlot(slotIndex, id, link, 1);
  else
    storage:clearSlot(slotIndex);
  end

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

addon.Items.addStorage(storageTabs);
