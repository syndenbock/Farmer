local addonName, addon = ...;

if (not addon.isDetectorAvailable('items')) then return end

local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local GetItemCount = _G.C_Item.GetItemCount;

local printIconMessageWithData = addon.Print.printIconMessageWithData;
local stringJoin = addon.stringJoin;
local getRarityColor = addon.getRarityColor;
local farmerFrame = addon.frame;

local SUBSPACE = farmerFrame:CreateSubspace();
local ItemPrint = addon:extend('ItemPrint', {});

local addonOptions = addon.SavedVariablesHandler(addonName, 'farmerOptions')
    .vars.farmerOptions;
local itemOptions = addonOptions.Items;
local coreOptions = addonOptions.Core;

ItemPrint.COLORS = {
  quest = {r = 1, g = 0.8, b = 0, 1},
};

local function getItemCount (identifier, includeBank)
  return GetItemCount(identifier, includeBank, false, includeBank, includeBank);
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

  return '(' .. stringJoin('/', bagCount, totalCount) .. ')';
end

local function formatItemCount (item, data)
  if (item.stackSize <= 1 and data.count <= 1) then
    return nil;
  end

  return 'x' .. BreakUpLargeNumbers(data.count);
end

local function updateData (item, data)
  data.count = (farmerFrame:GetMessageData(SUBSPACE, item.id) or 0) +
      data.count;
end

local formatItemName;

do
  local GetItemCraftedQualityByItemInfo = C_TradeSkillUI and C_TradeSkillUI.GetItemCraftedQualityByItemInfo;

  if (GetItemCraftedQualityByItemInfo) then
    formatItemName = function (item)
      local quality = GetItemCraftedQualityByItemInfo(item.link);

      if (quality) then
        return item.name .. addon.getCraftedQualityIcon(quality);
      else
        return item.name;
      end
    end
  else
    formatItemName = function (item)
      return item.name;
    end
  end
end

local function printItemDynamic (item, data, forceName)
  updateData(item, data);

  local text = stringJoin(' ',
    formatItemInfo(data),
    formatItemCount(item, data),
    formatAdditionalCounts(item, data)
  );

  if (text == '' or
      forceName == true or
      coreOptions.itemNames == true) then
    text = formatItemName(item) .. ' ' .. text;
  end

  printIconMessageWithData(SUBSPACE, item.id, data.count,
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
