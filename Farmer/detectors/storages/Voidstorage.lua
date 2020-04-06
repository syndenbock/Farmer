local addonName, addon = ...;

local Items = addon.Items;
local addItem = addon.StorageUtils.addItem;

local GetVoidItemInfo = _G.GetVoidItemInfo;
local GetVoidItemHyperlinkString = _G.GetVoidItemHyperlinkString;

local NUM_VOIDSTORAGE_TABS = 2;
local NUM_VOIDSTORAGE_SLOTS = 80;
local storage;

local function getCombinedIndex (tabIndex, slotIndex)
  return (tabIndex - 1) * NUM_VOIDSTORAGE_SLOTS + slotIndex;
end

local function readVoidStorage ()
  local bagContent = {};

  for tabIndex = 1, NUM_VOIDSTORAGE_TABS, 1 do
    for slotIndex = 1, NUM_VOIDSTORAGE_SLOTS, 1 do
      local id = GetVoidItemInfo(tabIndex, slotIndex);

      if (id ~= nil) then
        local combinedIndex = getCombinedIndex(tabIndex, slotIndex);
        --[[ For some reason, one function requires tabIndex and slotIndex
             and a related function requires slotIndex as if there was only
             one tab. Blizzard code at its best once again. ]]
        local link = GetVoidItemHyperlinkString(combinedIndex);

        addItem(bagContent, id, 1, link);
      end
    end
  end

  storage = bagContent;
end

addon:on('VOID_STORAGE_OPEN', function ()
  readVoidStorage();
  Items:updateCurrentInventory();
end);

addon:on('VOID_TRANSFER_DONE', readVoidStorage);

addon:on('VOID_STORAGE_CLOSE', function ()
  storage = nil;
end);

Items:addStorage(function ()
  return {storage};
end);
