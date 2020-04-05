local addonName, addon = ...;

local Items = addon.Items;
local addItem = addon.StorageUtils.addItem;

local Item = _G.Item;
local C_Item = _G.C_Item;
local IsItemDataCachedByID = C_Item.IsItemDataCachedByID;
local GetVoidItemInfo = _G.GetVoidItemInfo;
local GetVoidItemHyperlinkString = _G.GetVoidItemHyperlinkString;

local NUM_VOIDSTORAGE_TABS = 2;
local NUM_VOIDSTORAGE_SLOTS = 80;
local storage;

local function getCombinedIndex (tabIndex, slotIndex)
  return (tabIndex - 1) * NUM_VOIDSTORAGE_SLOTS + slotIndex;
end

local function readVoidStorage (callback)
  local bagContent = {};
  local callbackList = {};

  for tabIndex = 1, NUM_VOIDSTORAGE_TABS, 1 do
    for slotIndex = 1, NUM_VOIDSTORAGE_SLOTS, 1 do
      local id = GetVoidItemInfo(tabIndex, slotIndex);

      if (id ~= nil) then
        local combinedIndex = getCombinedIndex(tabIndex, slotIndex);

        if (IsItemDataCachedByID(id)) then
          --[[ For some reason, one function requires tabIndex and slotIndex
               and a related function requires slotIndex as if there was only
               one tab. Blizzard code at its best once again. ]]
          local link = GetVoidItemHyperlinkString(combinedIndex);

          addItem(bagContent, id, 1, link);
        else
          table.insert(callbackList, function (callback)
            local item = Item:CreateFromItemID(id);

            item:ContinueOnItemLoad(function ()
              local link = GetVoidItemHyperlinkString(combinedIndex);

              addItem(bagContent, id, 1, link);
              callback();
            end);
          end);
        end
      end
    end
  end

  addon:waitForCallbacks(callbackList, function ()
    storage = bagContent;

    if (type(callback) == 'function') then
      callback();
    end
  end);
end

addon:on('VOID_STORAGE_OPEN', function ()
  readVoidStorage(function ()
    Items:updateCurrentInventory();
  end);
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
