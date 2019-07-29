local addonName, addon = ...;

local UNITID_PLAYER = 'player';

local font = CreateFont('farmerFont');
local farmerFrame;

local currencyTable = {};
local bagCache = {};
local tradeStamp = 0;
local currentInventory;
local platesShown;

local widgetFlags = {
  mail = false,
  bank = false,
  guildbank = false,
  voidstorage = false,
  map = false,
  bagUpdate = false,
};

local function printMessage (...)
  farmerFrame:AddMessage(...)
  -- ChatFrame1:AddMessage(...)
end

local function setTrueScale (frame, scale)
    frame:SetScale(1)
    frame:SetScale(scale / frame:GetEffectiveScale())
end

local function getFirstKey (table)
  for key, value in pairs(table) do
    return key;
  end
end

local function clearWidgetFlags ()
  for key, value in pairs(widgetFlags) do
    widgetFlags[key] = false;
  end
end

local function fillCurrencyTable()
  -- a pretty ugly workaround, but WoW has no table containing the currency ids
  -- does not take long though, so it's fine (2ms on my shitty ass pc)
  for i = 1, 2000 do
    local info = {GetCurrencyInfo(i)}

    if (info[2]) then
      currencyTable[i] = info[2]
    end
  end
end

local function checkHideOptions ()
  if (widgetFlags.bank == true or
      widgetFlags.guildbank == true or
      widgetFlags.voidstorage == true) then
    return false;
  end

  if (farmerOptions.hideAtMailbox == true and
      widgetFlags.mail == true) then
    return false;
  end

  if (farmerOptions.hideOnExpeditions == true and
      IslandsPartyPoseFrame and
      IslandsPartyPoseFrame:IsShown() == true) then
    return false;
  end

  if (farmerOptions.hideInArena == true and
      IsActiveBattlefieldArena() == true) then
    return false;
  end

  return true;
end

local function performAutoLoot ()
  -- for i = GetNumLootItems(), 1, -1 do
  for i = 1, GetNumLootItems(), 1 do
    local info = {GetLootSlotInfo(i)}
    local locked = info[6]

    if (locked ~= true) then
      LootSlot(i)
    end
  end
end

local function printItem (texture, name, text, colors)
  local icon = ' |T' .. texture .. addon.vars.iconOffset

  if (text == nil or text == '') then
    printMessage(icon .. name, unpack(colors))
    return
  end

  if (farmerOptions.itemNames == true) then
    text = name .. ' ' .. text
  end

  printMessage(icon .. text, unpack(colors))
end

local function printItemCount (texture, name, text, count, colors, forceCount)
  local minimum = 1

  if (forceCount == true) then minimum = 0 end

  if (count > minimum) then
    if (text ~= nil and text ~= '') then
      text = 'x' .. count .. ' ' .. text
    else
      text = 'x' .. count
    end
  end

  printItem(texture, name, text, colors)
end

local function printStackableItemTotal (id, texture, name, count, colors)
  local text
  local totalCount = GetItemCount(id, true)

  if (totalCount < count) then
    totalCount = count
  end

  text = 'x' .. count .. ' (' .. totalCount .. ')'

  printItem(texture, name, text, colors)
end

local function printStackableItemBags (id, texture, name, count, colors)
  local text
  local bagCount = GetItemCount(id, false)
  local totalCount = GetItemCount(id, true)

  if (totalCount < count) then
    totalCount = count
    bagCount = count
  end

  text = 'x' .. count .. ' (' .. bagCount .. ')'

  printItem(texture, name, text, colors)
end

local function printStackableItemTotalAndBags (id, texture, name, count, colors)
  local text
  local bagCount = GetItemCount(id, false)
  local totalCount = GetItemCount(id, true)

  if (totalCount < count) then
    totalCount = count
    bagCount = count
  end

  text = 'x' .. count .. ' (' .. bagCount .. '/' .. totalCount .. ')'

  printItem(texture, name, text, colors)
end

local function printStackableItem (id, texture, name, count, colors)
  -- this should be the most common case, so we check this first
  if (farmerOptions.showTotal == true and
      farmerOptions.showBags == false) then
    printStackableItemTotal(id, texture, name, count, colors)
  elseif (farmerOptions.showTotal == true and
          farmerOptions.showBags == true) then
    printStackableItemTotalAndBags(id, texture, name, count, colors)
  elseif (farmerOptions.showTotal == false and
          farmerOptions.showBags == true) then
    printStackableItemBags(id, texture, name, count, colors)
  else
    printItemCount(texture, name, '', count, colors, true)
  end
end

local function printEquip (texture, name, text, count, colors)
  if (farmerOptions.itemNames == true) then
    text = '[' .. text .. ']'
  end
  printItemCount(texture, name, text, count, colors, false)
end

local function checkItemDisplay (itemId, itemLink)
  if (itemId and
      farmerOptions.focusItems[itemId] == true) then
    if (farmerOptions.special == true) then
      return true
    end
  elseif (farmerOptions.focus == true) then
    return false
  end

  local itemName, _itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
        itemSubType, itemStackCount, itemEquipLoc, texture,
        itemSellPrice, itemClassID, itemSubClassID, bindType, expacID,
        itemSetID, isCraftingReagent = GetItemInfo(itemLink)

  -- happens when caging a pet or when looting mythic keystones
  if (itemName == nil) then
    return false
  end

  if (farmerOptions.reagents == true and
      isCraftingReagent == true) then
    return true
  end

  if (farmerOptions.questItems == true and
      (itemClassID == LE_ITEM_CLASS_QUESTITEM or
       itemClassID == LE_ITEM_CLASS_KEY)) then
    return true
  end

  if (farmerOptions.recipes == true and
      itemClassID == LE_ITEM_CLASS_RECIPE) then
    return true
  end

  if (farmerOptions.rarity == true and
      itemRarity >= farmerOptions.minimumRarity) then
    return true
  end

  return false
end

local function handleItem (itemId, itemLink, count)
  if (checkItemDisplay(itemId, itemLink) ~= true) then return end

  local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
        itemSubType, itemStackCount, itemEquipLoc, texture,
        itemSellPrice, itemClassID, itemSubClassID, bindType, expacID,
        itemSetID, isCraftingReagent = GetItemInfo(itemLink)

  local colors = addon.rarityColors[itemRarity]

  -- crafting reagents
  if (isCraftingReagent == true) then
    if (itemId == chipId and hadChip == true) then
      hadChip = false
      return
    end

    colors = {0, 0.8, 0.8, 1}
  end

  -- quest items
  if (itemClassID == LE_ITEM_CLASS_QUESTITEM or
      itemClassID == LE_ITEM_CLASS_KEY) then
    colors = {1, 0.8, 0, 1}
  end

  -- artifact relics
  if (itemClassID == LE_ITEM_CLASS_GEM and
      itemSubClassID == LE_ITEM_GEM_ARTIFACTRELIC) then -- gem / artifact relics
    local text

    itemLevel = GetDetailedItemLevelInfo(itemLink)
    text = itemSubType .. ' ' .. itemLevel
    printEquip(texture, itemName, text, count, colors)
    return
  end

  -- equippables
  if (itemEquipLoc ~= '') then
    -- bags
    if (itemClassID == LE_ITEM_CLASS_CONTAINER) then
      printEquip(texture, itemName, itemSubType, count, colors)
      return
    end

    -- weapons
    if (itemClassID == LE_ITEM_CLASS_WEAPON) then
      local text
      itemLevel = GetDetailedItemLevelInfo(itemLink)
      text = itemSubType .. ' ' .. itemLevel
      printEquip(texture, itemName, text, count, colors)
      return
    end

    -- armor
    if (itemClassID == LE_ITEM_CLASS_ARMOR) then
      local text = _G[itemEquipLoc]

      itemLevel = GetDetailedItemLevelInfo(itemLink)

      if (itemEquipLoc == 'INVTYPE_TABARD') then
        -- text is already fine
      elseif (itemEquipLoc ==  'INVTYPE_CLOAK') then
        text = text .. ' ' .. itemLevel
      elseif (itemSubClassID == LE_ITEM_ARMOR_GENERIC) then
        text = text .. ' ' .. itemLevel -- fingers/trinkets
      elseif (itemSubClassID > LE_ITEM_ARMOR_SHIELD) then -- we all know shields are offhand
        text = itemSubType .. ' ' .. itemLevel
      else
        text = itemSubType .. ' ' .. text .. ' ' .. itemLevel
      end

      printEquip(texture, itemName, text, count, colors)
      return
    end
  end

  -- stackable items
  if (itemStackCount > 1) then
    printStackableItem(itemLink, texture, itemName, count, colors)
    return
  end

  -- all unspecified items
  printItemCount(texture, itemName, '', count, colors, false)
end

local function checkCurrencyDisplay (id)
  if (farmerOptions.ignoreHonor == true) then
    local honorId = 1585

    if (id == honorId) then
      return false
    end
  end

  return true
end

local function handleCurrency (id)
  local name, total, texture, earnedThisWeek, weeklyMax, totalMax, isDicovered,
        rarity = GetCurrencyInfo(id)
  local amount = currencyTable[id] or 0

  amount = total - amount

  -- warfronts show unknown currencies
  if (name == nil or texture == nil) then
    return
  end

  currencyTable[id] = total

  if (checkCurrencyDisplay(id) == false or
      checkHideOptions() == false) then return end

  if (amount <= 0) then return end

  local text = 'x' .. amount .. ' (' .. total .. ')'

  printItem(texture, name, text, {1, 0.9, 0, 1})
end

--[[
///#############################################################################
/// Event listeners
///#############################################################################
]]--

addon:on('PLAYER_LOGIN', function ()
  fillCurrencyTable();
end);

--[[ when having the mail open and accepting a queue, the MAIL_CLOSED event does
not fire, so we clear the flag after entering the world --]]
addon:on('PLAYER_ENTERING_WORLD', function ()
  clearWidgetFlags();

  if (platesShown ~= nil) then
    SetCVar('nameplateShowAll', platesShown);
    platesShown = nil;
  end
end);

addon:on('MAIL_SHOW', function ()
  widgetFlags.mail = true;
end);

addon:on('MAIL_CLOSED', function ()
  widgetFlags.mail = false;
end);

addon:on('BANKFRAME_OPENED', function ()
  widgetFlags.bank = true;
end);

addon:on('BANKFRAME_CLOSED', function ()
  widgetFlags.bank = false;
end);

addon:on('GUILDBANKFRAME_OPENED', function ()
  widgetFlags.guildbank = true;
end);

addon:on('GUILDBANKFRAME_CLOSED', function ()
  widgetFlags.guildbank = false;
end);

addon:on('VOID_STORAGE_OPEN', function ()
  widgetFlags.voidstorage = true;
end);

addon:on('VOID_STORAGE_CLOSE', function ()
  widgetFlags.voidstorage = false;
end);

LootFrame:SetAlpha(0);

addon:on('LOOT_READY', function (lootSwitch)
  --[[ the LOOT_READY sometimes fires multiple times when looting, so we only
    handle it once until loot is closed ]]

  if (widgetFlags.loot == true) then return end
  widgetFlags.loot = true

  widgetFlags.map = WorldMapFrame:IsShown()
  if (lootSwitch == true and
      farmerOptions.fastLoot == true) then
    performAutoLoot()
  else
    LootFrame:SetAlpha(1)
  end
end)

addon:on('LOOT_OPENED', function ()
  C_Timer.After(0, function ()
    if (widgetFlags.loot == true) then
      LootFrame:SetAlpha(1)
    end
  end)
end)

addon:on('LOOT_CLOSED', function ()
  widgetFlags.loot = false

  LootFrame:SetAlpha(0)

  if (widgetFlags.map == true) then
    WorldMapFrame:Show()
  end
end)

addon:on('CURRENCY_DISPLAY_UPDATE', function (id, total, amount)
  if (id == nil) then return end

  handleCurrency(id)
end)

addon:on('PLAYER_MONEY', function ()
  if (farmerOptions.money == false or
      checkHideOptions() == false) then
    return
  end

  local money = GetMoney()

  if (addon.vars.moneyStamp >= money) then
    addon.vars.moneyStamp = money
    return
  end

  local difference = money - addon.vars.moneyStamp
  local text = GetCoinTextureString(difference)

  addon.vars.moneyStamp = money

  printMessage(text, 1, 1, 1, 1)
end)

local function addItem (inventory, id, count, linkMap)
  if (inventory[id] == nil) then
    -- saving all links because gear has same ids, but different links
    inventory[id] = {
      links = linkMap,
      count = count,
    };
  else
    local itemInfo = inventory[id];

    itemInfo.count = itemInfo.count + count;

    for link in pairs(linkMap) do
      if (itemInfo.links[link] == nil) then
        itemInfo.links[link] = true;
      end
    end
  end
end

local function getBagContent (bagIndex)
  local bagContent = {};
  local slotCount = GetContainerNumSlots(bagIndex);

  for slotIndex = 1, slotCount, 1 do
    local id = GetContainerItemID(bagIndex, slotIndex);

    if (id ~= nil) then
      --[[ manually calculating the bag count is way faster than using
           GetItemCount --]]
      local _, count, _, _, _, _, link = GetContainerItemInfo(bagIndex, slotIndex);

      addItem(bagContent, id, count, {[link] = true});
    end
  end

  return bagContent;
end

local function getEquipment ()
  local equipment = {};

  -- slots 1-19 are gear, 20-23 are equipped bags
  for i = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED + NUM_BAG_SLOTS, 1 do
    local id = GetInventoryItemID(UNITID_PLAYER, i);

    if (id ~= nil) then
      local link = GetInventoryItemLink(UNITID_PLAYER, i) or id;

      addItem(equipment, id, 1, {[link] = true});
    end
  end

  return equipment;
end

local function getInventory ()
  local inventory = {};
  local equipment = getEquipment();

  for i = BACKPACK_CONTAINER, BACKPACK_CONTAINER + NUM_BAG_SLOTS, 1 do
    local bagContent = bagCache[i];

    if (bagContent ~= nil) then
      for itemId, itemInfo in pairs(bagContent) do
        addItem(inventory, itemId, itemInfo.count, itemInfo.links);
      end
    end
  end

  for itemId, itemInfo in pairs(equipment) do
    addItem(inventory, itemId, itemInfo.count, itemInfo.links);
  end

  return inventory;
end

local function checkInventory (timeStamp)
  timeStamp = timeStamp or GetTime();

  local inventory = getInventory();

  if (checkHideOptions() == false or
      timeStamp == tradeStamp) then
    currentInventory = inventory;
    return;
  end

  local new = {};

  for id, info in pairs(inventory) do
    if (currentInventory[id] == nil) then
      new[id] = {
        count = inventory[id].count,
        link = getFirstKey(inventory[id].links)
      };
    elseif (inventory[id].count > currentInventory[id].count) then
      local links = inventory[id].links;
      local currentLinks = currentInventory[id].links;
      local found = false;

      for link, value in pairs(links) do
        if (currentLinks[link] == nil) then
          found = true;
          new[id] = {
            count = inventory[id].count - currentInventory[id].count,
            link = link
          };
          break;
        end
      end

      if (found == false) then
        new[id] = {
          count = inventory[id].count - currentInventory[id].count,
          link = getFirstKey(links)
        };
      end
    end
  end

  for id, info in pairs(new) do
    handleItem(id, info.link, info.count);
  end

  currentInventory = inventory;
end

addon:on('PLAYER_LOGIN', function ()
  for i = BACKPACK_CONTAINER, BACKPACK_CONTAINER + NUM_BAG_SLOTS, 1 do
    bagCache[i] = getBagContent(i);
  end

  currentInventory = getInventory();
end);

addon:on('BAG_UPDATE', function (bagIndex)
  if (bagIndex < BACKPACK_CONTAINER or
      bagIndex > BACKPACK_CONTAINER + NUM_BAG_SLOTS) then
    return;
  end

  bagCache[bagIndex] = getBagContent(bagIndex);
end);

addon:on('BAG_UPDATE_DELAYED', function ()
  if (widgetFlags.bagUpdate == true) then return end

  widgetFlags.bagUpdate = true;

  --[[ BAG_UPDATE_DELAYED may fire multiple times in one frame, so we only
       check bags once on the next frame --]]
  C_Timer.After(0, function ()
    checkInventory(GetTime());
    widgetFlags.bagUpdate = false;
  end);
end);

addon:on('TRADE_CLOSED', function ()
  tradeStamp = GetTime();
end);

local function checkSlotForArtifact (slot)
  local quality = GetInventoryItemQuality(UNITID_PLAYER, slot);

  if (quality == LE_ITEM_QUALITY_ARTIFACT) then
    local id = GetInventoryItemID(UNITID_PLAYER, slot);
    local link = GetInventoryItemLink(UNITID_PLAYER, slot);

    addItem(currentInventory, id, 1, {[link] = true});
  end
end

--[[ we need to do this because when equipping artifact weapons, a second item
     appears in the offhand slot --]]
addon:on('PLAYER_EQUIPMENT_CHANGED', function ()
  checkSlotForArtifact(INVSLOT_MAINHAND);
  checkSlotForArtifact(INVSLOT_OFFHAND);
end);

--[[ handling nameplates when fishing --]]

do
  local FISHING_NAME = GetSpellInfo(131476);
  local fishingFlag = false;

  local function restorePlates ()
    if (platesShown ~= nil) then
      SetCVar('nameplateShowAll', platesShown);
      --[[ we change platesShown back to nil, so when someone disables the
      option and changes nameplates manually, the old value does not get
      applied anymore --]]
      platesShown = nil;
    end
  end

  addon:on('UNIT_SPELLCAST_CHANNEL_START', function (unit, target, spellid)
    if (farmerOptions.hidePlatesWhenFishing ~= true or
        unit ~= UNITID_PLAYER or
        InCombatLockdown() == true) then return end

    local spellName = GetSpellInfo(spellid);

    if (spellName == FISHING_NAME) then
      platesShown = GetCVar('nameplateShowAll');
      SetCVar('nameplateShowAll', 0);
    end
  end);

  addon:on('PLAYER_REGEN_ENABLED', function ()
    if (fishingFlag == true) then
      restorePlates();
      fishingFlag = false;
    end
  end);

  addon:on('UNIT_SPELLCAST_CHANNEL_STOP', function (unit, target, spellid)
    if (unit ~= UNITID_PLAYER or platesShown == nil) then return end

    if (InCombatLockdown() == true) then
      fishingFlag = true;
    else
      restorePlates();
    end
  end);
end

farmerFrame = CreateFrame('ScrollingMessageFrame', 'farmerFrame', UIParent)
farmerFrame:SetWidth(GetScreenWidth() / 2)
farmerFrame:SetHeight(GetScreenHeight() / 2)
-- farmerFrame:SetFrameStrata('DIALOG')
farmerFrame:SetFrameStrata('FULLSCREEN_DIALOG')
farmerFrame:SetFrameLevel(2)
farmerFrame:SetFading(true)
-- farmerFrame:SetTimeVisible(2)
farmerFrame:SetFadeDuration(0.5)
farmerFrame:SetMaxLines(20)
farmerFrame:SetInsertMode('TOP')
farmerFrame:SetFontObject(font)
setTrueScale(farmerFrame, 1)
farmerFrame:Show()

--[[
///#############################################################################
/// shared variables
///#############################################################################
--]]

addon.frame = farmerFrame
addon.font = font

addon:slash('test', function (id)
  id = id or 152505

  local _, link = GetItemInfo(id);

  handleItem(link, id, 1)
end);
