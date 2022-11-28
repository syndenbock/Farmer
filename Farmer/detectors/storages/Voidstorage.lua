local _, addon = ...;

local VOIDSTORAGE_FRAME_TYPE =
    addon.findGlobal('Enum', 'PlayerInteractionType', 'VoidStorageBanker');

if (VOIDSTORAGE_FRAME_TYPE == nil) then return end

local Storage = addon.import('Class/Storage');

local wipe = _G.wipe;
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
  for _, storage in ipairs(storageTabs) do
    storage:clearChanges();
  end
end

local function initVoidStorage ()
  initStorageTabs();
  readVoidStorage();
  clearVoidStorageChanges();
end

local function clearVoidStorage ()
  wipe(storageTabs);
end

addon.on('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', function (_, type)
  if (type == VOIDSTORAGE_FRAME_TYPE) then
    initVoidStorage();
  end
end);

addon.on('PLAYER_INTERACTION_MANAGER_FRAME_HIDE', function (_, type)
  if (type == VOIDSTORAGE_FRAME_TYPE) then
    clearVoidStorage();
  end
end);

addon.on('VOID_TRANSFER_DONE', readVoidStorage);

addon.Items.addStorage(storageTabs);
