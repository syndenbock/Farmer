local _, addon = ...;

if (addon.isClassic()) then return end

local Storage = addon.Factory.Storage;
local Items = addon.Items;

local GetVoidItemHyperlinkString = _G.GetVoidItemHyperlinkString;
local GetVoidItemInfo = _G.GetVoidItemInfo;

local NUM_VOIDSTORAGE_TABS = 2;
local NUM_VOIDSTORAGE_SLOTS = 80;
local storage;
local isOpen = false;

local function getCombinedIndex (tabIndex, slotIndex)
  return (tabIndex - 1) * NUM_VOIDSTORAGE_SLOTS + slotIndex;
end

local function readVoidStorageSlot (voidStorage, tabIndex, slotIndex)
  local id = GetVoidItemInfo(tabIndex, slotIndex);

  if (not id) then return end

  --[[ For some reason, one function requires tabIndex and slotIndex
       and a related function requires slotIndex as if there was only
       one tab. Blizzard code at its best once again. ]]
  local combinedIndex = getCombinedIndex(tabIndex, slotIndex);
  local link = GetVoidItemHyperlinkString(combinedIndex);

  voidStorage:addItem(id, link, 1);
end

local function readVoidStorageTab (voidStorage, tabIndex)
  for slotIndex = 1, NUM_VOIDSTORAGE_SLOTS, 1 do
    readVoidStorageSlot(voidStorage, tabIndex, slotIndex);
  end
end

local function readVoidStorage ()
  local voidStorage = Storage:new();

  for tabIndex = 1, NUM_VOIDSTORAGE_TABS, 1 do
    readVoidStorageTab(voidStorage, tabIndex);
  end

  storage = voidStorage;
end

addon.on('VOID_STORAGE_OPEN', function ()
  isOpen = true;
end);

addon.on({'VOID_STORAGE_UPDATE', 'VOID_STORAGE_CONTENTS_UPDATE',
    'VOID_TRANSFER_DONE'}, function ()
  if (isOpen == false) then return end

  local isInit = (storage == nil);

  readVoidStorage();

  if (isInit) then
    Items.updateCurrentInventory();
  end
end);

addon.on({'VOID_STORAGE_CLOSE', 'PLAYER_ENTERING_WORLD'}, function ()
  isOpen = false;
  storage = nil;
end);

Items.addStorage(function ()
  return {storage};
end);
