local addonName, addon = ...;

local EventUtils = addon.import('Utils/Events');
local C_Container = addon.import('polyfills/C_Container');

local GetContainerNumSlots = C_Container.GetContainerNumSlots;
local GetContainerItemInfo = C_Container.GetContainerItemInfo;
local UseContainerItem = C_Container.UseContainerItem;
local GetItemInfo = _G.GetItemInfo;

local MERCHANT_INTERACTION_TYPE = _G.Enum.PlayerInteractionType.Merchant;
local QUALITY_POOR = _G.Enum.ItemQuality.Poor;

local BagIndex = _G.Enum.BagIndex;
local InventoryConstants = _G.Constants.InventoryConstants

local BACKPACK_CONTAINER = BagIndex.Backpack;
local REAGENTBAG_CONTAINER = BagIndex.ReagentBag;

local NUM_BAG_SLOTS = InventoryConstants.NumBagSlots;
-- On Cataclysm Classic ReagentBag exists but not NumReagentBagSlots. Duh.
local NUM_REAGENTBAG_SLOTS = InventoryConstants.NumReagentBagSlots or 0;

local FIRST_BAG_SLOT = BACKPACK_CONTAINER + 1;
local LAST_BAG_SLOT = FIRST_BAG_SLOT + NUM_BAG_SLOTS;

local FIRST_REAGENTBAG_SLOT = REAGENTBAG_CONTAINER;
local LAST_REAGENTBAG_SLOT = NUM_REAGENTBAG_SLOTS;

local L = addon.L;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.SellAndRepair;


local function isItemTrash (quality)
  return (quality ~= nil and quality <= QUALITY_POOR);
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
      isItemTrash(info.quality)) then
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

  totalPrice = totalPrice + sellGrayItemsInBag(BACKPACK_CONTAINER);

  for bag = FIRST_BAG_SLOT, LAST_BAG_SLOT, 1 do
    totalPrice = totalPrice + sellGrayItemsInBag(bag);
  end

  for bag = FIRST_REAGENTBAG_SLOT, LAST_REAGENTBAG_SLOT, 1 do
    totalPrice = totalPrice + sellGrayItemsInBag(bag);
  end

  if (totalPrice > 0) then
    addon.printAddonMessage(L['Selling gray items for %s']:format(addon.formatMoney(totalPrice)));
  end
end

local function shouldAutoSell ()
  return (options.autoSell == true);
end

EventUtils.onInteractionFrameShow(MERCHANT_INTERACTION_TYPE, function ()
  if (shouldAutoSell()) then
    sellGrayItems();
  end
end);
