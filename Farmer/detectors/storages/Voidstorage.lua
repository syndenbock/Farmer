local addonName, addon = ...;

local Items = addon.Items;
local addItem = addon.StorageUtils.addItem;

local GetVoidItemHyperlinkString = _G.GetVoidItemHyperlinkString;
local GetItemInfoInstant = _G.GetItemInfoInstant;

local NUM_VOIDSTORAGE_SLOTS = 80 * 2;
local storage;

local function readVoidStorage ()
  local bagContent = {};

  for slotIndex = 1, NUM_VOIDSTORAGE_SLOTS, 1 do
    local link = GetVoidItemHyperlinkString(slotIndex);

    if (link ~= nil) then
      local id = GetItemInfoInstant(link);

      addItem(bagContent, id, 1, link);
    end
  end

  storage = bagContent;
end

addon:on('VOID_STORAGE_OPEN', function ()
  readVoidStorage();
  Items:updateCurrentInventory();
end);

addon:on('VOID_TRANSFER_DONE', function ()
  readVoidStorage();
end);

addon:on('VOID_STORAGE_CLOSE', function ()
  storage = nil;
end);

Items:addStorage(function ()
  return {storage};
end);
