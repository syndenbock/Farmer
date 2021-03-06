local addonName, addon = ...;

if (not addon.isDetectorAvailable('items')) then return end

local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local GetItemCount = _G.GetItemCount;

local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS;

local printIconMessageWithData = addon.Print.printIconMessageWithData;
local stringJoin = addon.stringJoin;
local farmerFrame = addon.frame;

local SUBSPACE = farmerFrame:CreateSubspace();
local ItemPrint = {};

local addonOptions = addon.SavedVariablesHandler(addonName, 'farmerOptions')
    .vars.farmerOptions;
local itemOptions = addonOptions.Items;
local coreOptions = addonOptions.Core;

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

local function getItemCount (identifier, includeBank)
  return GetItemCount(identifier, includeBank, false);
end

local function formatItemInfo (data)
  if (data.info == nil) then
    return nil;
  end

  return '[' .. data.info .. ']';
end

local function formatAdditionalCountsFragment (data, count)
  if (count <= data.count) then
    return nil;
  end

  return BreakUpLargeNumbers(count);
end

local function formatBagCount (item, data)
  if (itemOptions.showBagCount ~= true) then
    return nil;
  end

  return formatAdditionalCountsFragment(data,
      getItemCount(item.link, false));
end

local function formatTotalCount (item, data)
  if (itemOptions.showTotalCount ~= true) then
    return nil;
  end

  return formatAdditionalCountsFragment(data,
      getItemCount(item.link, true));
end

local function formatAdditionalCounts (item, data)
  local totalCount = formatTotalCount(item, data);
  local bagCount = formatBagCount(item, data);

  if (totalCount == nil and bagCount == nil) then
    return nil;
  end

  return '(' .. stringJoin({bagCount, totalCount}, '/') .. ')';
end

local function formatItemCount (item, data)
  if (item.stackSize <= 1 and data.count <= 1) then
    return nil;
  end

  return 'x' .. BreakUpLargeNumbers(data.count);
end

local function updateData (item, data)
  data.count = (farmerFrame:GetMessageData(SUBSPACE, item.link) or 0) +
      data.count;
end

local function printItemDynamic (item, data, forceName)
  updateData(item, data);

  local text = stringJoin({
    formatItemInfo(data),
    formatItemCount(item, data),
    formatAdditionalCounts(item, data),
  }, ' ');

  if (text == '' or
      forceName == true or
      coreOptions.itemNames ==  true) then
    text = item.name .. ' ' .. text;
  end

  printIconMessageWithData(SUBSPACE, item.link, data.count,
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
