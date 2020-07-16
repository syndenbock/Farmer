local addonName, addon = ...;

local GetDetailedItemLevelInfo = _G.GetDetailedItemLevelInfo;
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
local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS;
local INVTYPE_TABARD = 'INVTYPE_TABARD';
local INVTYPE_CLOAK = 'INVTYPE_CLOAK';

local Print = addon.Print;

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

local function checkRecipeOptions (itemInfo)
  return (saved.farmerOptions.recipes == true and
          itemInfo.classId == LE_ITEM_CLASS_RECIPE);
end

local function checkQuestItemOptions (itemInfo)
  return (saved.farmerOptions.questItems == true and
          (itemInfo.classId == LE_ITEM_CLASS_QUESTITEM or
           itemInfo.classId == LE_ITEM_CLASS_KEY));
end

local function checkReagentOptions (itemInfo)
  return (saved.farmerOptions.reagents == true and
          (itemInfo.isCraftingReagent == true or
           itemInfo.classId == LE_ITEM_CLASS_TRADEGOODS));
end

local function checkRarityOptions (itemInfo)
  return (saved.farmerOptions.rarity == true and
          itemInfo.rarity >= saved.farmerOptions.minimumRarity);
end

local function checkFocusOptions (itemInfo)
  local isFocused = (saved.farmerOptions.focusItems[itemInfo.id] == true);

  if (isFocused and saved.farmerOptions.special == true) then
    return true;
  end

  if (not isFocused and saved.farmerOptions.focus == true) then
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

local function getRarityColor (rarity)
  return {
    ITEM_QUALITY_COLORS[rarity].r,
    ITEM_QUALITY_COLORS[rarity].g,
    ITEM_QUALITY_COLORS[rarity].b,
  };
end

local function displayNonStackableItem (item, count, colors)
  Print.printItem(item.texture, item.name, count, nil, colors,
      {forceName = true, minimumCount = 1})
end

local function displayStackableItem (item, count, colors)
  Print.printStackableItem(item.link, item.texture, item.name, count, colors);
end

local function displayItem (item, count, colors)
  if (item.stackSize > 1) then
    displayStackableItem(item, count, colors);
  else
    displayNonStackableItem(item, count, colors);
  end
end

local function displayEquipment (item, text, count, colors)
  addon.Print.printEquip(item.texture, item.name, text, count, colors);
end

local function displayCraftingReagent (item, count)
  displayItem(item, count, {0, 0.8, 0.8});
end

local function isCraftingReagent (item)
  return (item.isCraftingReagent or item.classId == LE_ITEM_CLASS_TRADEGOODS);
end

local function handleCraftingReagent (item, count)
  if (isCraftingReagent(item)) then
    displayCraftingReagent(item, count);
    return true;
  else
    return false;
  end
end

local function displayQuestItem (item, count)
  displayItem(item, count, {1, 0.8, 0, 1});
end

local function isQuestItem (item)
  return (item.classID == LE_ITEM_CLASS_QUESTITEM or
          item.classID == LE_ITEM_CLASS_KEY);
end

local function handleQuestItem (item, count)
  if (isQuestItem(item)) then
    displayQuestItem(item, count);
    return true;
  else
    return false;
  end
end

local function displayArtifactRelic (item, count)
  local itemLevel = GetDetailedItemLevelInfo(item.link);
  local text = addon.stringJoin({itemLevel, item.subType}, ' ');

  displayEquipment(item, text, count, getRarityColor(item.rarity));
end

local function isArtifactRelic (item)
  return (item.classID == LE_ITEM_CLASS_GEM and
          item.subClassID == LE_ITEM_GEM_ARTIFACTRELIC);
end

local function handleArtifactRelic (item, count)
  if (isArtifactRelic(item)) then
    displayArtifactRelic(item, count);
    return true;
  else
    return false;
  end
end

local function isContainer (item)
  return (item.classId == LE_ITEM_CLASS_CONTAINER);
end

local function handleContainer (item, count)
  if (isContainer(item)) then
    displayEquipment(item, item.subType, count, getRarityColor(item.rarity));
    return true;
  else
    return false;
  end
end

local function displayWeapon (item, count)
  local itemLevel = GetDetailedItemLevelInfo(item.link);
  local text = addon.stringJoin({itemLevel, item.subType}, ' ');

  displayEquipment(item, text, count, getRarityColor(item.rarity));
end

local function isWeapon (item)
  return (item.classID == LE_ITEM_CLASS_WEAPON);
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
  local subClassID = item.subClassID;
  local itemLevel = GetDetailedItemLevelInfo(item.link);
  local slotText = getItemSlotText(equipLocation);
  local textList;
  local text;

  if (equipLocation == INVTYPE_TABARD) then
    textList = {slotText};
  elseif (equipLocation == INVTYPE_CLOAK) then
    textList = {itemLevel, slotText};
  elseif (subClassID == LE_ITEM_ARMOR_GENERIC) then
    textList = {itemLevel, slotText}; -- fingers/trinkets
  elseif (subClassID > LE_ITEM_ARMOR_SHIELD) then -- we all know shields are offhand
    textList = {itemLevel, slotText};
  else
    textList = {itemLevel, item.subType, slotText};
  end

  text = addon.stringJoin(textList, ' ');

  displayEquipment(item, text, count, getRarityColor(item.rarity));
end

local function isArmor (item)
  return (item.classID == LE_ITEM_CLASS_ARMOR)
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
  displayItem(item, count, getRarityColor(item.rarity));
end

local function handleItem (item, count)
  if (handleCraftingReagent(item, count)) then return end
  if (handleQuestItem(item, count)) then return end
  if (handleArtifactRelic(item, count)) then return end
  if (handleEquippable(item, count)) then return end

  displayUncategorizedItem(item, count);
end

local function checkItem (itemInfo, count)
  if (checkDisplayOptions(itemInfo)) then
    handleItem(itemInfo, count);
  end
end

addon.listen('NEW_ITEM', checkItem);
