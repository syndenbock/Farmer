local addonName, addon = ...;

local strupper = _G.strupper;
local strmatch = _G.strmatch;

local GetItemInfo = _G.GetItemInfo;
local GetDetailedItemLevelInfo = _G.GetDetailedItemLevelInfo;
local C_Soulbinds = _G.C_Soulbinds;
local IsItemConduitByItemInfo =
    C_Soulbinds and _G.C_Soulbinds.IsItemConduitByItemInfo;
local GetConduitCollectionDataByVirtualID =
    C_Soulbinds and C_Soulbinds.GetConduitCollectionDataByVirtualID

local LE_ITEM_CLASS_TRADEGOODS = _G.LE_ITEM_CLASS_TRADEGOODS;
local LE_ITEM_CLASS_QUESTITEM = _G.LE_ITEM_CLASS_QUESTITEM;
local LE_ITEM_CLASS_KEY = _G.LE_ITEM_CLASS_KEY;
local LE_ITEM_CLASS_RECIPE = _G.LE_ITEM_CLASS_RECIPE;
local LE_ITEM_CLASS_GEM = _G.LE_ITEM_CLASS_GEM;
local LE_ITEM_GEM_ARTIFACTRELIC = _G.LE_ITEM_GEM_ARTIFACTRELIC;
local LE_ITEM_CLASS_CONTAINER = _G.LE_ITEM_CLASS_CONTAINER;
local LE_ITEM_CLASS_WEAPON = _G.LE_ITEM_CLASS_WEAPON;
local LE_ITEM_CLASS_ARMOR = _G.LE_ITEM_CLASS_ARMOR;
local LE_ITEM_ARMOR_GENERIC = _G.LE_ITEM_ARMOR_GENERIC;
local LE_ITEM_ARMOR_SHIELD = _G.LE_ITEM_ARMOR_SHIELD;
local INVTYPE_TABARD = 'INVTYPE_TABARD';
local INVTYPE_CLOAK = 'INVTYPE_CLOAK';

local CONTAINER_PATTERN = _G.gsub(_G.gsub(
    _G.CONTAINER_SLOTS, '%%s', '%.+'),'%%d', '(%%d+)');

local Print = addon.Print;
local printItem = addon.ItemPrint.printItem;
local COLORS = addon.ItemPrint.COLORS;
local TooltipScanner = addon.TooltipScanner;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Items;

local function checkRecipeOptions (itemInfo)
  return (options.alwaysShowRecipes == true and
          itemInfo.classId == LE_ITEM_CLASS_RECIPE);
end

local function checkQuestItemOptions (itemInfo)
  return (options.alwaysShowQuestItems == true and
          (itemInfo.classId == LE_ITEM_CLASS_QUESTITEM or
           itemInfo.classId == LE_ITEM_CLASS_KEY));
end

local function checkReagentOptions (itemInfo)
  return (options.alwaysShowReagents == true and
          (itemInfo.isCraftingReagent == true or
           itemInfo.classId == LE_ITEM_CLASS_TRADEGOODS));
end

local function checkRarityOptions (itemInfo)
  return (options.filterByRarity == true and
          itemInfo.rarity >= options.minimumRarity);
end

local function checkFocusOptions (itemInfo)
  local isFocused = (options.focusItems[itemInfo.id] == true);

  if (isFocused and options.alwaysShowFocusItems == true) then
    return true;
  end

  if (not isFocused and options.onlyShowFocusItems == true) then
    return false;
  end

  return nil;
end

local function checkName (itemInfo)
  -- name can be nil when caging a pet or when looting a mythic keystone
  return (itemInfo.name ~= nil);
end

local function checkDisplayOptions (itemInfo)
  if (not Print.checkHideOptions()) then
    return false;
  end

  if (not checkName(itemInfo)) then
    return false;
  end

  local focusStatus = checkFocusOptions(itemInfo);

  if (focusStatus ~= nil) then
    return focusStatus;
  end

  if (checkRarityOptions(itemInfo)) then
    return true;
  end

  if (checkReagentOptions(itemInfo)) then
    return true;
  end

  if (checkQuestItemOptions(itemInfo)) then
    return true;
  end

  if (checkRecipeOptions(itemInfo)) then
    return true;
  end

  return false;
end

local function isCraftingReagent (item)
  return (item.isCraftingReagent or item.classId == LE_ITEM_CLASS_TRADEGOODS);
end

local function handleCraftingReagent (item, count)
  if (isCraftingReagent(item)) then
    printItem(item, {
      count = count,
      color = COLORS.reagent,
    });
    return true;
  else
    return false;
  end
end

local function isQuestItem (item)
  return (item.classId == LE_ITEM_CLASS_QUESTITEM or
          item.classId == LE_ITEM_CLASS_KEY);
end

local function handleQuestItem (item, count)
  if (isQuestItem(item)) then
    printItem(item, {
      count = count,
      color = COLORS.quest,
    });
    return true;
  else
    return false;
  end
end

local function displayArtifactRelic (item, count)
  local itemLevel = GetDetailedItemLevelInfo(item.link);

  printItem(item, {
    count = count,
    info = addon.stringJoin({itemLevel, item.subType}, ' '),
  });
end

local function isArtifactRelic (item)
  return (item.classId == LE_ITEM_CLASS_GEM and
          item.subClassId == LE_ITEM_GEM_ARTIFACTRELIC);
end

local function handleArtifactRelic (item, count)
  if (isArtifactRelic(item)) then
    displayArtifactRelic(item, count);
    return true;
  else
    return false;
  end
end

local function getConduitTypeString (type)
  for key, value in pairs(_G.Enum.SoulbindConduitType) do
    if (value == type) then
      return key;
    end
  end

  error('invalid conduit type: ' .. type);
end

local function getConduitText (item)
  local info = GetConduitCollectionDataByVirtualID(item.id);

  if (not info) then
    return 'Conduit';
  end

  local string = getConduitTypeString(info.conduitType);

  return _G['CONDUIT_TYPE_' .. strupper(string)] or string;
end

local function displayConduit (item, count)
  local itemLevel = GetDetailedItemLevelInfo(item.link);

  printItem(item, {
    count = count,
    info = addon.stringJoin({itemLevel, getConduitText(item)}, ' '),
  });
end

local function isConduit (item)
  if (addon.isClassic()) then
    return false;
  end

  local _, info = GetItemInfo(item.id);

  if (not info) then
    return false;
  end

  return IsItemConduitByItemInfo(info);
end

local function handleConduit (item, count)
  if (isConduit(item)) then
    displayConduit(item, count);
    return true;
  else
    return false;
  end
end

local function getContainerSize (item)
  local lines = TooltipScanner.getLinesByItemLink(item.link);

  for _, line in ipairs(lines) do
    local success, match = pcall(strmatch, line, CONTAINER_PATTERN);

    if (success == true and match ~= nil) then
      return tonumber(match);
    end
  end
end

local function displayContainer (item, count)
  local size = getContainerSize(item);

  printItem(item, {
    count = count,
    info = addon.stringJoin({size, item.subType}, ' '),
  });
end

local function isContainer (item)
  return (item.classId == LE_ITEM_CLASS_CONTAINER);
end

local function handleContainer (item, count)
  if (isContainer(item)) then
    displayContainer(item, count);
    return true;
  else
    return false;
  end
end

local function displayWeapon (item, count)
  local itemLevel = GetDetailedItemLevelInfo(item.link);

  printItem(item, {
    count = count,
    info = addon.stringJoin({itemLevel, item.subType}, ' '),
  });
end

local function isWeapon (item)
  return (item.classId == LE_ITEM_CLASS_WEAPON);
end

local function handleWeapon (item, count)
  if (isWeapon(item)) then
    displayWeapon(item, count);
    return true;
  else
    return false;
  end
end

local function getItemSlotText (equipLocation)
  return _G[equipLocation];
end

local function displayArmor (item, count)
  local equipLocation = item.equipLocation;
  local subClassId = item.subClassId;
  local itemLevel = GetDetailedItemLevelInfo(item.link);
  local slotText = getItemSlotText(equipLocation);
  local textList;
  local text;

  if (equipLocation == INVTYPE_TABARD) then
    textList = {slotText};
  elseif (equipLocation == INVTYPE_CLOAK) then
    textList = {itemLevel, slotText};
  elseif (subClassId == LE_ITEM_ARMOR_GENERIC) then
    textList = {itemLevel, slotText}; -- fingers/trinkets
  elseif (subClassId > LE_ITEM_ARMOR_SHIELD) then -- we all know shields are offhand
    textList = {itemLevel, slotText};
  else
    textList = {itemLevel, item.subType, slotText};
  end

  text = addon.stringJoin(textList, ' ');

  printItem(item, {
    count = count,
    info = text,
  });
end

local function isArmor (item)
  return (item.classId == LE_ITEM_CLASS_ARMOR)
end

local function handleArmor (item, count)
  if (isArmor(item)) then
    displayArmor(item, count);
    return true;
  else
    return false
  end
end

local function isEquippable (item)
  return (item.equipLocation and item.equipLocation ~= '');
end

local function handleEquippable (item, count)
  if (not isEquippable(item)) then return false end

  if (handleContainer(item, count)) then return true end
  if (handleWeapon(item, count)) then return true end
  if (handleArmor(item, count)) then return true end

  return false;
end

local function displayUncategorizedItem (item, count)
  printItem(item, {
    count = count,
  });
end

local function handleItem (item, count)
  if (handleCraftingReagent(item, count)) then return end
  if (handleQuestItem(item, count)) then return end
  if (handleArtifactRelic(item, count)) then return end
  if (handleConduit(item, count)) then return end
  if (handleEquippable(item, count)) then return end

  displayUncategorizedItem(item, count);
end

local function checkItem (itemInfo, count)
  if (checkDisplayOptions(itemInfo)) then
    handleItem(itemInfo, count);
  end
end

addon.listen('NEW_ITEM', checkItem);
