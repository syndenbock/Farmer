local addonName, addon = ...;

local function checkItemDisplay (itemId, itemLink)
  if (itemId ~= nil and
      farmerOptions.focusItems[itemId] == true) then
    if (farmerOptions.special == true) then
      return true;
    end
  elseif (farmerOptions.focus == true) then
    return false;
  end

  local itemName, _itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
        itemSubType, itemStackCount, itemEquipLoc, texture,
        itemSellPrice, itemClassID, itemSubClassID, bindType, expacID,
        itemSetID, isCraftingReagent = GetItemInfo(itemLink);

  -- happens when caging a pet or when looting mythic keystones
  if (itemName == nil) then
    return false;
  end

  if (farmerOptions.reagents == true and
      isCraftingReagent == true or
      itemClassID == LE_ITEM_CLASS_TRADEGOODS) then
    return true;
  end

  if (farmerOptions.questItems == true and
      (itemClassID == LE_ITEM_CLASS_QUESTITEM or
       itemClassID == LE_ITEM_CLASS_KEY)) then
    return true;
  end

  if (farmerOptions.recipes == true and
      itemClassID == LE_ITEM_CLASS_RECIPE) then
    return true;
  end

  if (farmerOptions.rarity == true and
      itemRarity >= farmerOptions.minimumRarity) then
    return true;
  end

  return false;
end

local function handleItem (itemId, itemLink, count)
  if (checkItemDisplay(itemId, itemLink) ~= true) then return end

  local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
        itemSubType, itemStackCount, itemEquipLoc, texture,
        itemSellPrice, itemClassID, itemSubClassID, bindType, expacID,
        itemSetID, isCraftingReagent = GetItemInfo(itemLink)

  local colors = {
    ITEM_QUALITY_COLORS[itemRarity].r,
    ITEM_QUALITY_COLORS[itemRarity].g,
    ITEM_QUALITY_COLORS[itemRarity].b,
  };

  -- quest items
  if (itemClassID == LE_ITEM_CLASS_QUESTITEM or
      itemClassID == LE_ITEM_CLASS_KEY) then
    colors = {1, 0.8, 0, 1};
  end

  -- artifact relics
  if (itemClassID == LE_ITEM_CLASS_GEM and
      itemSubClassID == LE_ITEM_GEM_ARTIFACTRELIC) then -- gem / artifact relics
    local text;

    itemLevel = GetDetailedItemLevelInfo(itemLink);
    text = addon:stringJoin({itemLevel, itemSubType}, ' ');
    addon.Print.printEquip(texture, itemName, text, count, colors);
    return;
  end

  -- equippables
  if (itemEquipLoc ~= '') then
    -- bags
    if (itemClassID == LE_ITEM_CLASS_CONTAINER) then
      addon.Print.printEquip(texture, itemName, itemSubType, count, colors);
      return;
    end

    -- weapons
    if (itemClassID == LE_ITEM_CLASS_WEAPON) then
      local text;

      itemLevel = GetDetailedItemLevelInfo(itemLink);
      text = addon:stringJoin({itemLevel, itemSubType}, ' ');
      addon.Print.printEquip(texture, itemName, text, count, colors);
      return;
    end

    -- armor
    if (itemClassID == LE_ITEM_CLASS_ARMOR) then
      local slot = _G[itemEquipLoc];
      local textList;
      local text;

      itemLevel = GetDetailedItemLevelInfo(itemLink);

      if (itemEquipLoc == 'INVTYPE_TABARD') then
        textList = {slot};
      elseif (itemEquipLoc ==  'INVTYPE_CLOAK') then
        textList = {itemLevel, slot};
      elseif (itemSubClassID == LE_ITEM_ARMOR_GENERIC) then
        textList = {itemLevel, slot} -- fingers/trinkets
      elseif (itemSubClassID > LE_ITEM_ARMOR_SHIELD) then -- we all know shields are offhand
        textList = {itemLevel, slot};
      else
        textList = {itemLevel, itemSubType, slot}
      end

      text = addon:stringJoin(textList, ' ');

      addon.Print.printEquip(texture, itemName, text, count, colors)
      return
    end
  end

  -- stackable items
  if (itemStackCount > 1) then
    addon.Print.printStackableItem(itemLink, texture, itemName, count, colors)
    return
  end

  -- all unspecified items
  addon.Print.printItem(texture, itemName, count, nil, colors, {forceName = true, minimumCount = 1})
end

addon:listen('NEW_ITEM', function (itemId, itemLink, count)
  if (addon.Print:checkHideOptions() == false) then return end

  handleItem(itemId, itemLink, count)
end);
