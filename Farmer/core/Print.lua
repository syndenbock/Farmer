local addonName, addon = ...;

local widgetFlags = {
  mail = false,
};

local function setTrueScale (frame, scale)
  frame:SetScale(1);
  frame:SetScale(scale / frame:GetEffectiveScale());
end

local font = CreateFont('farmerFont');
local farmerFrame = CreateFrame('ScrollingMessageFrame', 'farmerFrame', UIParent);

farmerFrame:SetWidth(GetScreenWidth() / 2);
farmerFrame:SetHeight(GetScreenHeight() / 2);

 -- farmerFrame:SetFrameStrata('DIALOG');
-- farmerFrame:SetFrameStrata('FULLSCREEN_DIALOG');
farmerFrame:SetFrameStrata('TOOLTIP');
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

local function checkHideOptions ()
  if (addon.savedVariables.farmerOptions.hideAtMailbox == true and
      widgetFlags.mail == true) then
    return false;
  end

  if (addon.savedVariables.farmerOptions.hideOnExpeditions == true and
      IslandsPartyPoseFrame and
      IslandsPartyPoseFrame:IsShown() == true) then
    return false;
  end

  if (addon.savedVariables.farmerOptions.hideInArena == true and
      IsActiveBattlefieldArena and
      IsActiveBattlefieldArena() == true) then
    return false;
  end

  return true;
end

local function printMessage (message, colors)
  colors = colors or {1, 1, 1};

  farmerFrame:AddMessage(message, unpack(colors, 1, 3));
  -- ChatFrame1:AddMessage(...)
end

local function printItem (texture, name, count, text, colors, options)
  count = count or 1;
  options = options or {};

  local icon = addon:getIcon(texture);
  local itemName;
  local itemCount;
  local message;

  if (options.minimumCount == nil or count > options.minimumCount) then
    itemCount = 'x' .. BreakUpLargeNumbers(count);
  end

  if (addon.savedVariables.farmerOptions.itemNames == true or options.forceName == true) then
    itemName = name;
  end

  message = addon:stringJoin({itemName, itemCount, text}, ' ');

  if (message == '') then
    message = name;
  end

  printMessage(icon .. ' ' .. message, colors);
end

local function getFormattedItemCount (id, includeBank)
  return BreakUpLargeNumbers(GetItemCount(id, includeBank, false));
end

local function printStackableItemTotal (id, texture, name, count, colors)
  local totalCount = getFormattedItemCount(id, true);
  local text = addon:stringJoin({'(', totalCount, ')'}, '');

  printItem(texture, name, count, text, colors);
end

local function printStackableItemBags (id, texture, name, count, colors)
  local bagCount = getFormattedItemCount(id, false);
  local text = addon:stringJoin({'(', bagCount, ')'}, '');

  printItem(texture, name, count, text, colors);
end

local function printStackableItemTotalAndBags (id, texture, name, count, colors)
  local bagCount = getFormattedItemCount(id, false);
  local totalCount = getFormattedItemCount(id, true);
  local text = addon:stringJoin({'(', bagCount, '/', totalCount, ')'}, '');

  printItem(texture, name, count, text, colors);
end

local function printStackableItem (id, texture, name, count, colors)
  -- this should be the most common case, so we check this first
  if (addon.savedVariables.farmerOptions.showTotal == true and
      addon.savedVariables.farmerOptions.showBags == false) then
    printStackableItemTotal(id, texture, name, count, colors)
  elseif (addon.savedVariables.farmerOptions.showTotal == true and
      addon.savedVariables.farmerOptions.showBags == true) then
    printStackableItemTotalAndBags(id, texture, name, count, colors)
  elseif (addon.savedVariables.farmerOptions.showTotal == false and
      addon.savedVariables.farmerOptions.showBags == true) then
    printStackableItemBags(id, texture, name, count, colors)
  else
    printItem(texture, name, count, nil, colors)
  end
end

local function printEquip (texture, name, text, count, colors)
  if (text ~= nil and text ~= '') then
    text = '[' .. text .. ']';
  end

  printItem(texture, name, count, text, colors, {minimumCount = 1});
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
  checkHideOptions = checkHideOptions,
};

addon.frame = farmerFrame
addon.font = font
