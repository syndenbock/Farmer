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

local function readGuildBank (callback)
  --[[ This variable only becomes available after the guild bank has been
       opened ]]
  local MAX_GUILDBANK_SLOTS_PER_TAB = _G.MAX_GUILDBANK_SLOTS_PER_TAB;
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
    storage = guildContent;

    if (type(callback) == 'function') then
      callback();
    end
  end);
end

addon:on('GUILDBANKFRAME_OPENED', function ()
  readGuildBank(function ()
    Items:updateCurrentInventory();
  end);
end);

addon:on('GUILDBANKBAGSLOTS_CHANGED', function ()
  readGuildBank();
end);

addon:on('GUILDBANKFRAME_CLOSED', function ()
  storage = nil;
end);


Items:addStorage(function ()
  return {storage};
end);
