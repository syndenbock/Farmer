local addonName, addon = ...;

local widgetFlags = {
  mail = false,
  bank = false,
  guildbank = false,
  voidstorage = false,
  bagUpdate = false,
};

local function setTrueScale (frame, scale)
  frame:SetScale(1);
  frame:SetScale(scale / frame:GetEffectiveScale());
end

local font = CreateFont('farmerFont');
local farmerFrame;

farmerFrame = CreateFrame('ScrollingMessageFrame', 'farmerFrame', UIParent);
farmerFrame:SetWidth(GetScreenWidth() / 2);
farmerFrame:SetHeight(GetScreenHeight() / 2);
 farmerFrame:SetFrameStrata('DIALOG');
--farmerFrame:SetFrameStrata('FULLSCREEN_DIALOG');
farmerFrame:SetFrameLevel(2);
farmerFrame:SetFading(true);
-- farmerFrame:SetTimeVisible(2);
farmerFrame:SetFadeDuration(0.5);
farmerFrame:SetMaxLines(20);
farmerFrame:SetInsertMode('TOP');
farmerFrame:SetFontObject(font);
setTrueScale(farmerFrame, 1);
farmerFrame:Show();

--[[ when having the mail open and accepting a queue, the MAIL_CLOSED event does
not fire, so we clear the flag after entering the world --]]
addon:on('PLAYER_ENTERING_WORLD', function ()
  for key, value in pairs(widgetFlags) do
    widgetFlags[key] = false;
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

local function printMessage (message, colors, markers)
  farmerFrame:AddMessage(message, unpack(colors, 1, 3));
  -- ChatFrame1:AddMessage(...)
end

local function printItem (texture, name, text, colors)
  local icon = ' |T' .. texture .. addon.vars.iconOffset .. '|t'

  if (text == nil or text == '') then
    printMessage(icon .. name, colors)
    return
  end

  if (farmerOptions.itemNames == true) then
    text = name .. ' ' .. text
  end

  printMessage(icon .. text, colors)
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

--[[
///#############################################################################
/// shared variables
///#############################################################################
--]]

addon.Print = {
  printMessage = printMessage,
  printItem = printItem,
  printEquip = printEquip,
  printStackableItem = printStackableItem,
  printItemCount = printItemCount,
  checkHideOptions = checkHideOptions,
};

addon.frame = farmerFrame
addon.font = font
