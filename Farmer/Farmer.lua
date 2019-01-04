local addonName, farmerVars = ...

local chipId = 129100
local font = CreateFont('farmerFont')
local _, chipName = GetItemInfoInstant(chipId)

local messagePatterns = {
  CHAT_MSG_LOOT = {
    {
      LOOT_ITEM_SELF_MULTIPLE, {
        {
          '%%s',
          '(.+)'
        }, {
          '(%%d)',
          '(%%d+)'
        }
      }
    },
    {
      LOOT_ITEM_SELF, {
        {
          '%%s',
          '(.+)',
        }
      }
    },
    {
      LOOT_ITEM_PUSHED_SELF_MULTIPLE,
      {
        {
          '%%s',
          '(.+)'
        },
        {
          '(%%d)',
          '(%%d+)'
        }
      }
    },
    {
      LOOT_ITEM_PUSHED_SELF, {
        {
          '%%s',
          '(.+)',
        }
      }
    },
    {
      LOOT_ITEM_BONUS_ROLL_SELF_MULTIPLE, {
        {
          '%%s',
          '(.+)'
        }, {
          '(%%d)',
          '(%%d+)'
        }
      }
    },
    {
      LOOT_ITEM_BONUS_ROLL_SELF, {
        {
          '%%s',
          '(.+)',
        }
      }
    },
  },
  CHAT_MSG_CURRENCY = {
    {
      CURRENCY_GAINED_MULTIPLE, {
        {
          '%%s',
          '(.+)'
        }, {
          '(%%d)',
          '(%%d+)'
        }
      }
    },
    {
      CURRENCY_GAINED, {
        {
          '%%s',
          '(.+)',
        }
      }
    }
  }
}

local farmerFrame
local events = {}
local mapShown
local hadChip = false
local lootStack = nil
local lootTimeStamp = 0
local playerName
local playerFullName
local currencyTable = {}

function fillCurrencyTable()
  for i = 1, GetCurrencyListSize() do
    local info = {GetCurrencyListInfo(i)}
    local name = info[1]
    local count = info[6]

    if (name) then
      currencyTable[name] = count
    end
  end
end

function events:PLAYER_LOGIN ()
  playerName = {UnitFullName('player')}
  playerFullName = playerName[1] .. '-' .. playerName[2]
  playerName = playerName[1]

  fillCurrencyTable()
end

for msg, replacements in pairs(messagePatterns) do
  local new = {}
  for i = 1, #replacements do
    local content = replacements[i]
    local message = content[1]
    local patterns = content[2]
    for k = 1, #patterns do
      local pattern = patterns[k]
      message = gsub(message, pattern[1], pattern[2])
    end
    message = '^' .. message .. '$'
    new[i] = message
  end
  messagePatterns[msg] = new
end

local function printTable (table)
  for i, v in pairs(table) do
    print(i, ' - ', v)
  end
end

local function printMessage (...)
  farmerFrame:AddMessage(...)
  -- ChatFrame1:AddMessage(...)
end

local function setTrueScale (frame, scale)
    frame:SetScale(1)
    frame:SetScale(scale / frame:GetEffectiveScale())
end

local function checkHideOptions ()
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
  local time = GetTime()

  if ((time - lootTimeStamp) < 0.3) then
    return
  end

  lootTimeStamp = time

  -- for i = GetNumLootItems(), 1, -1 do
  for i = 1, GetNumLootItems(), 1 do
    LootSlot(i)
  end
end

local function printItem (texture, text, colors)
  local icon = ' |T' .. texture .. farmerVars.iconOffset

  printMessage(icon .. text, unpack(colors))
end

local function printItemCount (texture, name, text, count, colors)
  if (count > 1) then
    text = 'x' .. count .. ' ' .. text
  end

  if (farmerOptions.itemNames == true or
      text == '') then
    text = name .. ' ' .. text
  end

  printItem(texture, text, colors)
end

local function printStackableItemTotal (id, texture, name, count, totalCount, colors)
  local text

  totalCount = totalCount + GetItemCount(id, true)

  if (totalCount < count) then
    totalCount = count
  end

  text = 'x' .. count .. ' (' .. totalCount .. ')'

  if (farmerOptions.itemNames == true) then
    text = name .. ' ' .. text
  end

  printItem(texture, text, colors)
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

  if (farmerOptions.itemNames == true) then
    text = name .. ' ' .. text
  end

  printItem(texture, text, colors)
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

  if (farmerOptions.itemNames == true) then
    text = name .. ' ' .. text
  end

  printItem(texture, text, colors)
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
    printItemCount(texture, name, '', count, colors)
  end
end

local function printEquip (texture, name, text, count, colors)
  if (farmerOptions.itemNames == true) then
    text = '[' .. text .. ']'
  end
  printItemCount(texture, name, text, count, colors)
end

local function checkItemDisplay (itemLink)
  local itemId = GetItemInfoInstant(itemLink)

  if (itemId and
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
        itemSetID, isCraftingReagent = GetItemInfo(itemLink)

  -- happens when caging a pet
  if (itemName == nil) then
    return
  end

  if (farmerOptions.reagents == true and
      isCraftingReagent == true) then
    return true;
  end

  if (farmerOptions.questItems == true and
      itemClassID == 12) then
    return true;
  end

  if (farmerOptions.rarity == true and
      itemRarity >= farmerOptions.minimumRarity) then
    return true;
  end

  return false;
end

local function handleItem (itemLink, count, totalCount)
  if (checkItemDisplay(itemLink) ~= true) then return end

  local itemName, _itemLink, itemRarity, itemLevel, itemMinLevel, itemType,
        itemSubType, itemStackCount, itemEquipLoc, texture,
        itemSellPrice, itemClassID, itemSubClassID, bindType, expacID,
        itemSetID, isCraftingReagent = GetItemInfo(itemLink)
  local colors = farmerVars.rarityColors[itemRarity]
  local itemId = GetItemInfoInstant(itemLink)

  -- crafting reagents
  if (isCraftingReagent == true) then
    if (itemId == chipId and hadChip == true) then
      hadChip = false
      return
    end

    printStackableItem(itemLink, texture, itemName, count, totalCount, {0, 0.8, 0.8, 1})
    return
  end

  -- legion jewelcrafting colored gem chips
  if (itemId ~= nil) then
    if ((itemId >= 130200 and
         itemId <= 130204) or
        itemId == 129099) then
      hadChip = true
      printStackableItem(chipId, texture, itemName, count, totalCount, {1, 1, 1, 1})
      return
    end
  end

  -- quest items
  if (itemClassID == 12) then
    printItemCount(texture, itemName, '', count, {1, 0.8, 0, 1})
    return
  end

  -- stackable items
  if (itemStackCount > 1) then
    printStackableItem(itemLink, texture, itemName, count, totalCount, colors)
    return
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

  -- all unspecified items
  printItemCount(texture, itemName, '', count, colors)
end

function handleCurrency (link, total)
  local name, amount, texture, earnedThisWeek, weeklyMax, totalMax, isDicovered,
        rarity = GetCurrencyInfo(link)
  local count = currencyTable[name] or 0;
  local count = total - count;

  currencyTable[name] = total;

  if (checkHideOptions() == false) then return end

  if (count <= 0) then return end

  local text = 'x' .. count .. ' (' .. amount .. ')'

  if (farmerOptions.itemNames == true) then
    text = name .. ' ' .. text;
  end

  printItem(texture, text, {1, 0.9, 0, 1})
end

function displayLoot ()
  if (lootStack == nil) then
    return
  end

  if (checkHideOptions() == false) then
    lootStack = nil
    return
  end

  for key, value in pairs (lootStack) do
    if (value.count > 0) then
      handleItem(key, value.count, value.totalCount)
      value.count = 0
    end
  end
end

--[[
///#############################################################################
/// Event listeners
///#############################################################################
]]--

function events:UNIT_INVENTORY_CHANGED (arg)
  if (arg ~= 'player') then return end
end

LootFrame:SetAlpha(0)

function events:LOOT_READY (lootSwitch)
  mapShown = WorldMapFrame:IsShown()
  if (lootSwitch == true and
      farmerOptions.fastLoot == true) then
    performAutoLoot()
    if (LootFrame:IsShown() == true) then
      LootFrame:SetAlpha(1)
    end
  else
    LootFrame:SetAlpha(1)
  end
end

function events:LOOT_CLOSED ()
  LootFrame:SetAlpha(0)
  if (mapShown == true) then
    WorldMapFrame:Show()
    mapShown = false
  end
end

function events:CHAT_MSG_LOOT (message, _, _, _, unit)
  -- prevents string parsing in groups/raids
  if (unit ~= playerName and
      unit ~= playerFullName) then
    return
  end

  local list = messagePatterns.CHAT_MSG_LOOT

  if (lootStack == nil) then
    lootStack = {}
  end

  for k = 1, #list do
    local v = list[k]
    local link, amount = string.match(message, v)

    if (link ~= nil) then

      if (amount == nil) then
        amount = 1
      else
        amount = tonumber(amount)
      end

      if (lootStack[link] == nil) then
        lootStack[link] = {
          ['count'] = amount,
          ['totalCount'] = amount
        }
      else
        lootStack[link].count = lootStack[link].count + amount
        lootStack[link].totalCount = lootStack[link].totalCount + amount
      end

      -- if (farmerFrame:GetScript('OnUpdate') == nil) then
      -- end

      farmerFrame:SetScript('OnUpdate', function ()
        farmerFrame:SetScript('OnUpdate', nil)
        displayLoot()
      end)

      return
    end
  end
end

function events:BAG_UPDATE_DELAYED ()
  if (lootStack == nil) then
    return
  end

  if (checkHideOptions() == false) then
    lootStack = nil
    return
  end

  for key, value in pairs (lootStack) do
    if (value.count > 0) then
      handleItem(key, value.count, 0)
    end
  end

  lootStack = nil
end

function events:CURRENCY_DISPLAY_UPDATE (id, total)
  if (id == nil) then return end

  handleCurrency(id, total);
end

function events:PLAYER_MONEY ()
  if (farmerOptions.money == false) then
    return
  end

  local money = GetMoney()

  if (farmerVars.moneyStamp >= money) then
    farmerVars.moneyStamp = money
    return
  end

  local difference = money - farmerVars.moneyStamp
  local text = GetCoinTextureString(difference)

  farmerVars.moneyStamp = money

  printMessage(text, 1, 1, 1, 1)
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

local function eventHandler (self, event, ...)
  events[event](self, ...)
end

farmerFrame:SetScript('OnEvent', eventHandler)

for k, v in pairs(events) do
  farmerFrame:RegisterEvent(k)
end

--[[
///#############################################################################
/// shared variables
///#############################################################################
--]]

farmerVars.frame = farmerFrame
farmerVars.font = font
