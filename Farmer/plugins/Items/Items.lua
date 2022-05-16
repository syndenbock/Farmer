local addonName, addon = ...;

if (not addon.isDetectorAvailable('items')) then return end

local strupper = _G.strupper;
local strmatch = _G.strmatch;

local GetItemInfo = _G.GetItemInfo;
local GetDetailedItemLevelInfo = _G.GetDetailedItemLevelInfo;
local C_Soulbinds = _G.C_Soulbinds;
local IsItemConduitByItemInfo =
    C_Soulbinds and _G.C_Soulbinds.IsItemConduitByItemInfo;
local GetConduitCollectionDataByVirtualID =
    C_Soulbinds and C_Soulbinds.GetConduitCollectionDataByVirtualID

local ITEM_CLASS_ENUM = _G.Enum.ItemClass;
local ARMOR_SUBCLASS_ENUM = _G.Enum.ItemArmorSubclass;
local GEM_SUBCLASS_ENUM = _G.Enum.ItemGemSubclass;

local ITEM_CLASS_TRADEGOODS = ITEM_CLASS_ENUM.Tradegoods;
local ITEM_CLASS_QUESTITEM = ITEM_CLASS_ENUM.Questitem;
local ITEM_CLASS_KEY = ITEM_CLASS_ENUM.Key;
local ITEM_CLASS_RECIPE = ITEM_CLASS_ENUM.Recipe;
local ITEM_CLASS_GEM = ITEM_CLASS_ENUM.Gem;
local ITEM_CLASS_CONTAINER = ITEM_CLASS_ENUM.Container;
local ITEM_CLASS_WEAPON = ITEM_CLASS_ENUM.Weapon;
local ITEM_CLASS_ARMOR = ITEM_CLASS_ENUM.Armor;

local ITEM_SUBCLASS_ARMOR_GENERIC = ARMOR_SUBCLASS_ENUM.Generic;
local ITEM_SUBCLASS_ARMOR_SHIELD = ARMOR_SUBCLASS_ENUM.Shield;

local ITEM_SUBCLASS_GEM_ARTIFACTRELIC = GEM_SUBCLASS_ENUM.Artifactrelic;

local INVTYPE_TABARD = 'INVTYPE_TABARD';
local INVTYPE_CLOAK = 'INVTYPE_CLOAK';

local CONTAINER_PATTERN = _G.gsub(_G.gsub(
    _G.CONTAINER_SLOTS, '%%s', '%.+'),'%%d', '(%%d+)');

local Print = addon.Print;
local printItem = addon.ItemPrint.printItem;
local printItemWithName = addon.ItemPrint.printItemWithName;
local COLORS = addon.ItemPrint.COLORS;
local TooltipScanner = addon.TooltipScanner;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Items;

local function isRecipe (itemInfo)
  return (itemInfo.classId == ITEM_CLASS_RECIPE);
end

local function checkRecipeOptions (itemInfo)
  return (options.alwaysShowRecipes == true and
          isRecipe(itemInfo));
end

local function isQuestItem (itemInfo)
  return (itemInfo.classId == ITEM_CLASS_QUESTITEM or
          itemInfo.classId == ITEM_CLASS_KEY);
end

local function checkQuestItemOptions (itemInfo)
  return (options.alwaysShowQuestItems == true and
      isQuestItem(itemInfo));
end

local function isCraftingReagent (itemInfo)
  return (itemInfo.isCraftingReagent or
      itemInfo.classId == ITEM_CLASS_TRADEGOODS);
end

local function checkReagentOptions (itemInfo)
  return (options.alwaysShowReagents == true and
          isCraftingReagent(itemInfo));
end

local function checkRarityOptions (itemInfo)
  return (options.filterByRarity == true and
          itemInfo.rarity >= options.minimumRarity);
end

local function checkFocusOptions (itemInfo)
  local isFocused = (options.focusItems[itemInfo.id] == true);

  if (isFocused) then
    if (options.alwaysShowFocusItems == true) then
      return true;
    end
  else
    if (options.onlyShowFocusItems == true) then
      return false;
    end
  end

  return nil;
end

local function checkName (itemInfo)
  -- name can be nil when caging a pet or when looting a mythic keystone
  return (itemInfo.name ~= nil);
end

local function checkDisplayOptions (itemInfo, count)
  if (count < 0) then
    return false;
  end

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

local function getItemLevelText (item)
  if (options.showEquipmentItemLevels ~= true) then
    return nil;
  end

  return GetDetailedItemLevelInfo(item.link);
end

local function handleQuestItem (item, count)
  if (isQuestItem(item)) then
    printItemWithName(item, {
      count = count,
      color = COLORS.quest,
    });
    return true;
  else
    return false;
  end
end

local function displayArtifactRelic (item, count)
  printItem(item, {
    count = count,
    info = addon.stringJoin({getItemLevelText(item), item.subType}, ' '),
  });
end

local function isArtifactRelic (item)
  return (item.classId == ITEM_CLASS_GEM and
          item.subClassId == ITEM_SUBCLASS_GEM_ARTIFACTRELIC);
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

  local text = getConduitTypeString(info.conduitType);

  return _G['CONDUIT_TYPE_' .. strupper(text)] or text;
end

local function displayConduit (item, count)
  printItem(item, {
    count = count,
    info = addon.stringJoin({getItemLevelText(item), getConduitText(item)}, ' '),
  });
end

local function isConduit (item)
  if (IsItemConduitByItemInfo == nil) then
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
  return (item.classId == ITEM_CLASS_CONTAINER);
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
  printItem(item, {
    count = count,
    info = addon.stringJoin({getItemLevelText(item), item.subType}, ' '),
  });
end

local function isWeapon (item)
  return (item.classId == ITEM_CLASS_WEAPON);
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
  local itemLevelText = getItemLevelText(item);
  local slotText = getItemSlotText(equipLocation);
  local textList;
  local text;

  if (equipLocation == INVTYPE_TABARD) then
    textList = {slotText};
  elseif (equipLocation == INVTYPE_CLOAK) then
    textList = {itemLevelText, slotText};
  elseif (subClassId == ITEM_SUBCLASS_ARMOR_GENERIC) then
    textList = {itemLevelText, slotText}; -- fingers/trinkets
  elseif (subClassId > ITEM_SUBCLASS_ARMOR_SHIELD) then -- we all know shields are offhand
    textList = {itemLevelText, slotText};
  else
    textList = {itemLevelText, item.subType, slotText};
  end

  text = addon.stringJoin(textList, ' ');

  printItem(item, {
    count = count,
    info = text,
  });
end

local function isArmor (item)
  return (item.classId == ITEM_CLASS_ARMOR)
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
  printItemWithName(item, {
    count = count,
  });
end

local function handleItem (item, count)
  if (handleQuestItem(item, count)) then return end
  if (handleArtifactRelic(item, count)) then return end
  if (handleConduit(item, count)) then return end
  if (handleEquippable(item, count)) then return end

  displayUncategorizedItem(item, count);
end

addon.listen('ITEM_CHANGED', function (itemInfo, count)
  if (checkDisplayOptions(itemInfo, count)) then
    handleItem(itemInfo, count);
  end
end);
