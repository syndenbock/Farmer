local addonName, addon = ...;

local Items = addon.Items;
local addItem = addon.StorageUtils.addItem;

local Item = _G.Item;
local C_Item = _G.C_Item;
local IsItemDataCachedByID = C_Item.IsItemDataCachedByID;
local GetItemInfoInstant = _G.GetItemInfoInstant;
local GetGuildBankItemInfo = _G.GetGuildBankItemInfo;
local GetGuildBankItemLink = _G.GetGuildBankItemLink;
local MAX_GUILDBANK_TABS = _G.MAX_GUILDBANK_TABS;

local storage;

local function readGuildBank ()
  --[[ This variable only becomes available after the guild bank has been
       opened. If the guild bank frame is replaced by an addon, it will stay
       unavailable and we use the hardcoded value from Blizzard's code.
       Again, I have no clue why did not put a global constant in the code for
       this.]]
  local MAX_GUILDBANK_SLOTS_PER_TAB = _G.MAX_GUILDBANK_SLOTS_PER_TAB or 98;
  local guildContent = {};
  local callbackList = {};

  for tabIndex = 1, MAX_GUILDBANK_TABS, 1 do
    for slotIndex = 1, MAX_GUILDBANK_SLOTS_PER_TAB, 1 do
      local link = GetGuildBankItemLink(tabIndex, slotIndex);

      if (link ~= nil) then
        local id = GetItemInfoInstant(link);
        local info = {GetGuildBankItemInfo(tabIndex, slotIndex)};
        local count = info[2];

        if (IsItemDataCachedByID(id)) then
          addItem(guildContent, id, count, link);
        else
          table.insert(callbackList, function (callback)
            local item = Item:CreateFromItemID(id);

            item:ContinueOnItemLoad(function ()
              --[[ If data was not ready yet, link is not nil but has no data.
                   Therefor we refresh the link.]]
              link = GetGuildBankItemLink(tabIndex, slotIndex);
              addItem(guildContent, id, count, link);
              callback();
            end);
          end);
        end
      end
    end
  end

  addon:waitForCallbacks(callbackList, function ()
    local init = (storage == nil);

    storage = guildContent;

    if (init == true) then
      Items:updateCurrentInventory();
    end
  end);
end

addon:on('GUILDBANKBAGSLOTS_CHANGED', readGuildBank);

addon:on('GUILDBANKFRAME_CLOSED', function ()
  storage = nil;
end);

Items:addStorage(function ()
  return {storage};
end);
