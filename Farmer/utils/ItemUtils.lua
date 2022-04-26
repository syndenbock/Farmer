local _, addon = ...;

local DoesItemExistByID = _G.C_Item.DoesItemExistByID;
local Item = _G.Item;
local GetItemInfo = _G.GetItemInfo;

local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS;

function addon.getRarityColor (rarity)
  return ITEM_QUALITY_COLORS[rarity];
end

function addon.fetchItemLink (id, link, callback, ...)
  --[[ Apparently you can actually have non-existent items in your bags ]]
  if (not DoesItemExistByID(id)) then
    return callback(id, link, ...);
  end

  local item = Item:CreateFromItemID(id);
  local params = {...};

  item:ContinueOnItemLoad(function()
    --[[ The original link does contain enough information for a call to
          GetItemInfo which then returns a complete itemLink ]]
    --[[ Some items like mythic keystones and caged pets don't get a new link
          by GetItemInfo ]]
    link = select(2, GetItemInfo(link)) or link;
    callback(id, link, unpack(params));
  end);
end
