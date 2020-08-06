local addonName, addon = ...;

local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local GetItemCount = _G.GetItemCount;

local ItemPrint = {};

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Items;

addon.ItemPrint = ItemPrint;

local printItem = addon.Print.printItem;

local function getFormattedItemCount (id, includeBank)
  return BreakUpLargeNumbers(GetItemCount(id, includeBank, false));
end

local function printStackableItemTotal (id, texture, name, count, colors)
  local totalCount = getFormattedItemCount(id, true);
  local text = addon.stringJoin({'(', totalCount, ')'}, '');

  printItem(texture, name, count, text, colors);
end

local function printStackableItemBags (id, texture, name, count, colors)
  local bagCount = getFormattedItemCount(id, false);
  local text = addon.stringJoin({'(', bagCount, ')'}, '');

  printItem(texture, name, count, text, colors);
end

local function printStackableItemTotalAndBags (id, texture, name, count, colors)
  local bagCount = getFormattedItemCount(id, false);
  local totalCount = getFormattedItemCount(id, true);
  local text = addon.stringJoin({'(', bagCount, '/', totalCount, ')'}, '');

  printItem(texture, name, count, text, colors);
end

local function printItemIncludingTotal (id, texture, name, count, colors)
  if (options.showBagCount == true) then
    printStackableItemTotalAndBags(id, texture, name, count, colors);
  else
    printStackableItemTotal(id, texture, name, count, colors);
  end
end

local function printItemExcludingTotal (id, texture, name, count, colors)
  if (options.showBagCount == true) then
    printStackableItemBags(id, texture, name, count, colors);
  else
    printItem(texture, name, count, nil, colors);
  end
end

local function printStackableItem (id, texture, name, count, colors)
  if (options.showTotalCount == true) then
    printItemIncludingTotal(id, texture, name, count, colors);
  else
    printItemExcludingTotal(id, texture, name, count, colors);
  end
end

local function printEquip (texture, name, text, count, colors)
  if (text and text ~= '') then
    text = '[' .. text .. ']';
  end

  printItem(texture, name, count, text, colors, {minimumCount = 1});
end

local function displayNonStackableItem (item, count, colors)
  printItem(item.texture, item.name, count, nil, colors,
      {forceName = true, minimumCount = 1});
end

local function displayStackableItem (item, count, colors)
  printStackableItem(item.link, item.texture, item.name, count, colors);
end

local function displayItem (item, count, colors)
  if (item.stackSize > 1) then
    displayStackableItem(item, count, colors);
  else
    displayNonStackableItem(item, count, colors);
  end
end

ItemPrint.displayItem = displayItem;

function ItemPrint.displayEquipment (item, text, count, colors)
  printEquip(item.texture, item.name, text, count, colors);
end

function ItemPrint.displayCraftingReagent (item, count)
  displayItem(item, count, {0, 0.8, 0.8});
end

function ItemPrint.displayQuestItem (item, count)
  displayItem(item, count, {1, 0.8, 0, 1});
end
