local addonName, addon = ...;

local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local GetItemCount = _G.GetItemCount;

local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS;

local printIconMessageWithData = addon.Print.printIconMessageWithData;
local stringJoin = addon.stringJoin;
local farmerFrame = addon.frame;

local SUBSPACE_IDENTIFIER = farmerFrame:CreateSubspace();
local ItemPrint = {};

local addonOptions = addon.SavedVariablesHandler(addonName, 'farmerOptions')
    .vars.farmerOptions.Items;

addon.ItemPrint = ItemPrint;


ItemPrint.COLORS = {
  reagent = {0, 0.8, 0.8},
  quest = {1, 0.8, 0, 1},
};

local function getRarityColor (rarity)
  local colors = ITEM_QUALITY_COLORS[rarity];

  return {
    colors.r,
    colors.g,
    colors.b,
  };
end

local function getFormattedItemCount (id, includeBank)
  return BreakUpLargeNumbers(GetItemCount(id, includeBank, false));
end

local function formatItemInfo (data)
  if (data.info == nil) then return
    nil;
  end

  return '[' .. data.info .. ']';
end

local function formatAdditionalCounts (item)
  if (item.stackSize <= 1) then
    return nil;
  end

  local bagCount = nil;
  local totalCount = nil;

  if (addonOptions.showBagCount == true) then
    bagCount = getFormattedItemCount(item.link, false);
  end

  if (addonOptions.showTotalCount == true) then
    totalCount = getFormattedItemCount(item.link, true);
  end

  if (bagCount ~= nil or totalCount ~= nil) then
    return '(' .. stringJoin({bagCount, totalCount}, '/') .. ')';
  else
    return nil;
  end
end

local function formatItemCount (item, data)
  if (item.stackSize > 1 or data.count > 1) then
    return 'x' .. BreakUpLargeNumbers(data.count);
  else
    return nil;
  end
end

local function updateData (item, data)
  data.count = (farmerFrame:GetMessageData(SUBSPACE_IDENTIFIER, item.link) or 0) + data.count;
end

local function printItemDynamic (item, data, forceName)
  updateData(item, data);

  local text = stringJoin({
    formatItemInfo(data),
    formatItemCount(item, data),
    formatAdditionalCounts(item),
  }, ' ');

  if (text == '' or
      forceName == true or
      addonOptions.itemNames ==  true) then
    text = item.name .. ' ' .. text;
  end

  printIconMessageWithData(SUBSPACE_IDENTIFIER, item.link, data.count,
      item.texture, text, data.color or getRarityColor(item.rarity));
end

local function printItemWithName (item, data)
  printItemDynamic(item, data, true);
end

local function printItem (item, data)
  printItemDynamic(item, data, false);
end

ItemPrint.printItem = printItem;
ItemPrint.printItemWithName = printItemWithName;
ItemPrint.getRarityColor = getRarityColor;
