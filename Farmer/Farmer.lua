local addonName, addon = ...

local chipId = 129100
local font = CreateFont('farmerFont')
local _, chipName = GetItemInfoInstant(chipId)


local itemStringReplacement = {
  pattern = '%%s',
  replacement = '(%%|%.+%%|r)'
}

local itemCountReplacement = {
  pattern = '%%d',
  replacement = '(%%d+)'
}

local messagePatterns = {
  {
    LOOT_ITEM_SELF_MULTIPLE, {
      itemStringReplacement,
      itemCountReplacement
    }
  },
  {
    LOOT_ITEM_SELF, {
      itemStringReplacement
    }
  },
  {
    LOOT_ITEM_PUSHED_SELF_MULTIPLE,
    {
      itemStringReplacement,
      itemCountReplacement
    }
  },
  {
    LOOT_ITEM_PUSHED_SELF, {
      itemStringReplacement
    }
  },
  {
    LOOT_ITEM_BONUS_ROLL_SELF_MULTIPLE, {
      itemStringReplacement,
      itemCountReplacement
    }
  },
  {
    LOOT_ITEM_BONUS_ROLL_SELF, {
      itemStringReplacement
    }
  }
}

local farmerFrame
local currencyTable = {}
local mailOpen = false
local hadChip = false
local lootFlag = false
local updateFlag = false
local bagTimeStamp = 0
local mapShown
local lootStack
local playerName
local playerFullName

local function printMessage (...)
  farmerFrame:AddMessage(...)
  -- ChatFrame1:AddMessage(...)
end

local function setTrueScale (frame, scale)
    frame:SetScale(1)
    frame:SetScale(scale / frame:GetEffectiveScale())
end

for i = 1, #messagePatterns do
  local content = messagePatterns[i]
  local message = content[1]
  local patterns = content[2]

  message = message:gsub('%.', '%%.')

  for k = 1, #patterns do
    local pattern = patterns[k]

    message = message:gsub(pattern.pattern, pattern.replacement)
  end

  message = '^' .. message .. '$'
  messagePatterns[i] = message
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
  if (farmerOptions.hideAtMailbox == true and
      mailOpen == true) then
    return false
  end

  if (farmerOptions.hideOnExpeditions == true and
      IslandsPartyPoseFrame and
      IslandsPartyPoseFrame:IsShown() == true) then
    return false
  end

  if (farmerOptions.hideInArena == true and
      IsActiveBattlefieldArena() == true) then
    return false
  end

  return true
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

local function printStackableItemTotal (id, texture, name, count, totalCount, colors)
  local text

  totalCount = totalCount + GetItemCount(id, true)

  if (totalCount < count) then
    totalCount = count
  end

  text = 'x' .. count .. ' (' .. totalCount .. ')'

  printItem(texture, name, text, colors)
end

local function printStackableItemBags (id, texture, name, count, totalCount, colors)
  local text
  local bagCount = totalCount + GetItemCount(id, false)

  totalCount = totalCount + GetItemCount(id, true)

  if (totalCount < count) then
    totalCount = count
    bagCount = count
  end

  text = 'x' .. count .. ' (' .. bagCount .. ')'

  printItem(texture, name, text, colors)
end

local function printStackableItemTotalAndBags (id, texture, name, count, totalCount, colors)
  local text
  local bagCount = totalCount + GetItemCount(id, false)

  totalCount = totalCount + GetItemCount(id, true)

  if (totalCount < count) then
    totalCount = count
    bagCount = count
  end

  text = 'x' .. count .. ' (' .. bagCount .. '/' .. totalCount .. ')'

  printItem(texture, name, text, colors)
end

local function printStackableItem (id, texture, name, count, totalCount, colors)
  -- this should be the most common case, so we check this first
  if (farmerOptions.showTotal == true and
      farmerOptions.showBags == false) then
    printStackableItemTotal(id, texture, name, count, totalCount, colors)
  elseif (farmerOptions.showTotal == true and
          farmerOptions.showBags == true) then
    printStackableItemTotalAndBags(id, texture, name, count, totalCount, colors)
  elseif (farmerOptions.showTotal == false and
          farmerOptions.showBags == true) then
    printStackableItemBags(id, texture, name, count, totalCount, colors)
  else
    printItemCount(texture, name, '', count, colors, true)
  end
end

local function printEquip (texture, name, text, count, colors)
  if (farmerOptions.itemNames == true) then
    text = '[' .. text .. ']'
  end
  printItemCount(texture, name, text, count, colors)
end

local function isGemChip (itemId)
  if (itemId == nil) then return false end

  if ((itemId >= 130200 and
       itemId <= 130204) or
      itemId == 129099) then
    return true
  else
    return false
  end
end

local function checkItemDisplay (itemLink)
  local itemId = GetItemInfoInstant(itemLink)

  if (itemId and
      farmerOptions.focusItems[itemId] == true) then
    if (farmerOptions.special == true) then
      return true
    end
  elseif (farmerOptions.focus == true) then
    return false
  end

  local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
        itemSubType, itemStackCount, itemEquipLoc, texture,
        itemSellPrice, itemClassID, itemSubClassID, bindType, expacID,
        itemSetID, isCraftingReagent = GetItemInfo(itemLink)

  -- happens when caging a pet
  if (itemName == nil) then
    return
  end

  if (farmerOptions.reagents == true and
      (isGemChip(itemId) == true or
       isCraftingReagent == true)) then
    return true
  end

  if (farmerOptions.questItems == true and
      itemClassID == 12) then
    return true
  end

  if (farmerOptions.recipes == true and
      itemClassID == 9) then
    return true
  end

  if (farmerOptions.rarity == true and
      itemRarity >= farmerOptions.minimumRarity) then
    return true
  end

  return false
end

local function handleItem (itemLink, count, totalCount)
  if (checkItemDisplay(itemLink) ~= true) then return end

  local itemId = GetItemInfoInstant(itemLink)
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

  -- legion jewelcrafting colored gem chips
  if (isGemChip(itemId) == true) then
    hadChip = true
    itemLink = chipId
    colors = {0, 0.8, 0.8, 1}
  end

  -- quest items
  if (itemClassID == 12) then
    colors = {1, 0.8, 0, 1}
  end

  -- artifact relics
  if (itemClassID == 3 and
      itemSubClassID == 11) then -- gem / artifact relics
    local text

    itemLevel = GetDetailedItemLevelInfo(itemLink)
    text = itemSubType .. ' ' .. itemLevel
    printEquip(texture, itemName, text, count, colors)
    return
  end

  -- equippables
  if (itemEquipLoc ~= '') then
    -- bags
    if (itemClassID == 1) then
      printEquip(texture, itemName, itemSubType, count, colors)
      return
    end

    -- weapons
    if (itemClassID == 2) then
      local text
      itemLevel = GetDetailedItemLevelInfo(itemLink)
      text = itemSubType .. ' ' .. itemLevel
      printEquip(texture, itemName, text, count, colors)
      return
    end

    -- armor
    if (itemClassID == 4) then
      local text = _G[itemEquipLoc]
      itemLevel = GetDetailedItemLevelInfo(itemLink)

      if (itemEquipLoc == 'INVTYPE_TABARD') then
        -- text is already fine
      elseif (itemEquipLoc ==  'INVTYPE_CLOAK') then
        text = text .. ' ' .. itemLevel
      elseif (itemSubClassID == 0) then
        text = text .. ' ' .. itemLevel -- fingers/trinkets
      elseif (itemSubClassID > 4) then -- we all know shields are offhand
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
    printStackableItem(itemLink, texture, itemName, count, totalCount, colors)
    return
  end

  -- all unspecified items
  printItemCount(texture, itemName, '', count, colors)
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

local function displayLootBeforeUpdate ()
  if (lootStack == nil) then
    return
  end

  if (checkHideOptions() == false) then
    lootStack = nil
    return
  end

  for key, value in pairs (lootStack) do
    if (value.count > 0) then
      handleItem(value.itemLink, value.count, value.totalCount)
      value.count = 0
    end
  end
end

local function displayLootAfterUpdate ()
  if (lootStack == nil) then
    return
  end

  if (checkHideOptions() == false) then
    lootStack = nil
    return
  end

  for key, value in pairs (lootStack) do
    if (value.count > 0) then
      handleItem(value.itemLink, value.count, 0)
    end
  end

  lootStack = nil
end

--[[
///#############################################################################
/// Event listeners
///#############################################################################
]]--

addon:on('PLAYER_LOGIN', function ()
  playerName = {UnitFullName('player')}
  playerFullName = playerName[1] .. '-' .. playerName[2]
  playerName = playerName[1]

  fillCurrencyTable()
end)

--[[ when having the mail open and accepting a queue, the MAIL_CLOSED event does
not fire, so we clear the flag after entering the world --]]
addon:on('PLAYER_ENTERING_WORLD', function ()
  lootFlag = false
  mailOpen = false
  bagTimeStamp = 0
end)

addon:on('MAIL_SHOW', function ()
  mailOpen = true
end)

addon:on('MAIL_CLOSED', function ()
  mailOpen = false
end)

LootFrame:SetAlpha(0)

addon:on('LOOT_READY', function (lootSwitch)
  --[[ the LOOT_READY sometimes fires multiple times when looting, so we only
    handle it once until loot is closed ]]

  if (lootFlag == true) then return end
  lootFlag = true

  mapShown = WorldMapFrame:IsShown()
  if (lootSwitch == true and
      farmerOptions.fastLoot == true) then
    performAutoLoot()
  else
    LootFrame:SetAlpha(1)
  end
end)

addon:on('LOOT_OPENED', function ()
  C_Timer.After(0, function ()
    if (lootFlag == true) then
      LootFrame:SetAlpha(1)
    end
  end)
end)

addon:on('LOOT_CLOSED', function ()
  lootFlag = false

  LootFrame:SetAlpha(0)

  if (mapShown == true) then
    WorldMapFrame:Show()
  end
end)

addon:on('CHAT_MSG_LOOT', function (message, _, _, _, unit)
  -- prevents string parsing in groups/raids
  if (unit ~= playerName and
      unit ~= playerFullName) then
    return
  end

  lootStack = lootStack or {}

  for k = 1, #messagePatterns do
    local v = messagePatterns[k]
    local link, amount = string.match(message, v)

    if (link ~= nil) then
      local itemId = GetItemInfoInstant(link)
      local elapsed = GetTime() - bagTimeStamp

      if (amount == nil) then
        amount = 1
      else
        amount = tonumber(amount)
      end

      if (lootStack[itemId] == nil) then
        lootStack[itemId] = {
          ['count'] = amount,
          ['totalCount'] = amount,
          ['itemLink'] = link
        }
      else
        lootStack[itemId].count = lootStack[itemId].count + amount
        lootStack[itemId].totalCount = lootStack[itemId].totalCount + amount
      end

      if (updateFlag == false) then
        updateFlag = true
        -- skipping one frame to accumulate all loot messages in a frame first
        C_Timer.After(0, function ()
          if (elapsed < 0.3) then
            displayLootAfterUpdate()
          else
            displayLootBeforeUpdate()
          end

          bagTimeStamp = 0
          updateFlag = false

          --[[ Blizzard's event system is very very very very very very very
            unreliable, so we clean up --]]
          C_Timer.After(0.3, function ()
            if (updateFlag == false) then
              displayLootAfterUpdate()
            end
          end)
        end)
      end

      return
    end
  end
end)

addon:on('BAG_UPDATE_DELAYED', function ()
  if (lootStack == nil) then
    bagTimeStamp = GetTime()
  else
    bagTimeStamp = 0
    displayLootAfterUpdate()
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


--[[ handling nameplates when fishing --]]

do
  local FISHING_ID = 131476;
  local platesShown = nil;

  addon:on('UNIT_SPELLCAST_CHANNEL_START', function (unit, target, spellid)
    if (farmerOptions.hidePlatesWhenFishing == true and
        unit == 'player' and
        spellid == FISHING_ID) then
      platesShown = GetCVar('nameplateShowAll');
      SetCVar('nameplateShowAll', 0);
    end
  end);

  addon:on('UNIT_SPELLCAST_CHANNEL_STOP', function (unit, target, spellid)
    if (platesShown ~= nil and
        unit == 'player' and
        spellid == FISHING_ID) then
      SetCVar('nameplateShowAll', platesShown);

      --[[ we change platesShown back to nil, so when someone disables the
        option and changes nameplates manually, the old value does not get
        applied anymore --]]
      platesShown = nil;
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
  if (id ~= nil) then
    handleItem(id, 1, 1)
  end
end)
