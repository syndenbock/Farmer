local addonName, addon = ...;

local GetContainerNumSlots = _G.GetContainerNumSlots;
local GetContainerItemInfo = _G.GetContainerItemInfo;
local GetItemInfo = _G.GetItemInfo;
local UseContainerItem = _G.UseContainerItem;

local L = addon.L;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.SellAndRepair;

local FIRST_BAG = _G.BACKPACK_CONTAINER;
local LAST_BAG = FIRST_BAG + _G.NUM_BAG_SLOTS;
local QUALITY_COMMON = _G.Enum.ItemQuality.Poor;

local function isItemGray (quality)
  return (quality ~= nil and quality == QUALITY_COMMON);
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
  return (not readable or options.autoSellSkipReadable == false);
end

local function sellItemIfGray (bag, slot)
  local info = {GetContainerItemInfo(bag, slot)};
  local locked = info[3];
  local quality = info[4];
  local readable = info[5];

  -- empty info means empty bag slot
  if (info[1] == nil) then return 0 end;

  if (not locked and
      shouldSellReadableItem(readable) and
      isItemGray(quality)) then
    local itemCount = info[2];
    local itemLink = info[7];
    local price = getItemSellPrice(itemLink) * itemCount;

    sellitem(bag, slot);

    return price;
  else
    return 0;
  end
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
    print(L['Selling gray items for %s']:format(addon.formatMoney(totalPrice)));
  end
end

local function shouldAutoSell ()
  return (options.autoSell == true);
end

local function onMerchantOpened ()
  if (shouldAutoSell()) then
    sellGrayItems();
  end
end

addon.on('MERCHANT_SHOW', onMerchantOpened);
