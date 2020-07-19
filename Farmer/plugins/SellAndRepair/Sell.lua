local addonName, addon = ...;

local GetContainerNumSlots = _G.GetContainerNumSlots;
local GetContainerItemInfo = _G.GetContainerItemInfo;
local GetItemInfo = _G.GetItemInfo;
local UseContainerItem = _G.UseContainerItem;

local L = addon.L;

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

local FIRST_BAG = _G.BACKPACK_CONTAINER;
local LAST_BAG = FIRST_BAG + _G.NUM_BAG_SLOTS;
local QUALITY_COMMON = _G.Enum.ItemQuality.Poor;

local function isItemGray (quality)
  return (quality <= QUALITY_COMMON);
end

local function sellitem (bag, slot)
  UseContainerItem(bag, slot);

  -- This feels cleaner, but uses the mouse cursor which is intrusive
  --ClearCursor();
  --PickupContainerItem(bag, slot);
  --PickupMerchantItem();
end

local function getItemSellPrice (itemLink)
  local info = {GetItemInfo(itemLink)};

  return info[11] or 0;
end

local function shouldSellReadableItem (readable)
  return (not readable or saved.farmerOptions.autoSellSkipReadable == false);
end

local function sellItemIfGray (bag, slot)
  local info = {GetContainerItemInfo(bag, slot)};
  local locked = info[3];
  local quality = info[4];
  local readable = info[5];

  -- empty info means empty bag slot
  if (info[1] == nil) then return 0 end;

  if (locked or not
      shouldSellReadableItem(readable) or not
      isItemGray(quality)) then
    return 0;
  end

  local itemLink = info[7];
  local price = getItemSellPrice(itemLink);

  sellitem(bag, slot);

  return price;
end

local function sellGrayItemsInBag (bag)
  local price = 0;

  for slot = 1, GetContainerNumSlots(bag), 1 do
    price = price + sellItemIfGray(bag, slot);
  end

  return price;
end

local function sellGrayItems ()
	local totalPrice = 0;

  for bag = FIRST_BAG, LAST_BAG, 1 do
    totalPrice = totalPrice + sellGrayItemsInBag(bag);
  end

  if (totalPrice > 0) then
    print(L['Selling gray items for'] .. ' ' ..
        addon.formatMoney(totalPrice));
  end
end

local function shouldAutoSell ()
  return (saved.farmerOptions.autoSell == true);
end

local function onMerchantOpened ()
  if (shouldAutoSell()) then
    sellGrayItems();
  end
end

addon.on('MERCHANT_SHOW', onMerchantOpened);
