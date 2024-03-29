local addonName, addon = ...;

local C_Container = addon.import('polyfills/C_Container');

local GetContainerNumSlots = C_Container.GetContainerNumSlots;
local GetContainerItemInfo = C_Container.GetContainerItemInfo;
local UseContainerItem = C_Container.UseContainerItem;
local GetItemInfo = _G.GetItemInfo;

local REAGENT_CONTAINER = _G.REAGENT_CONTAINER or 5;

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
  local info = GetContainerItemInfo(bag, slot);

  -- empty info means empty bag slot
  if (info == nil) then return 0 end;

  if (not info.isLocked and
      shouldSellReadableItem(info.isReadable) and
      isItemGray(info.quality)) then
    local price = getItemSellPrice(info.itemID) * info.stackCount;

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

  if (addon.isRetail()) then
    totalPrice = totalPrice + sellGrayItemsInBag(REAGENT_CONTAINER);
  end

  if (totalPrice > 0) then
    addon.printAddonMessage(L['Selling gray items for %s']:format(addon.formatMoney(totalPrice)));
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
