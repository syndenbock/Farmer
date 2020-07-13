local _, addon = ...;

local unpack = _G.unpack;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local IsActiveBattlefieldArena = _G.IsActiveBattlefieldArena;
local GetItemCount = _G.GetItemCount;

local mailIsOpen = false;

local function setTrueScale (frame, scale)
  frame:SetScale(1);
  frame:SetScale(scale / frame:GetEffectiveScale());
end

local farmerFrame = _G.CreateFrame('ScrollingMessageFrame', 'farmerFrame', _G.UIParent);
local font = _G.CreateFont('farmerFont');

local Print = {
  font = font,
  frame = farmerFrame,
};

addon.Print = Print;

farmerFrame:SetWidth(_G.GetScreenWidth() / 2);
farmerFrame:SetHeight(_G.GetScreenHeight() / 2);

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
  mailIsOpen = false;
end);

addon:on('MAIL_SHOW', function ()
  mailIsOpen = true;
end);

addon:on('MAIL_CLOSED', function ()
  mailIsOpen = false;
end);

local function getFormattedItemCount (id, includeBank)
  return BreakUpLargeNumbers(GetItemCount(id, includeBank, false));
end

local function printStackableItemTotal (id, texture, name, count, colors)
  local totalCount = getFormattedItemCount(id, true);
  local text = addon:stringJoin({'(', totalCount, ')'}, '');

  Print.printItem(texture, name, count, text, colors);
end

local function printStackableItemBags (id, texture, name, count, colors)
  local bagCount = getFormattedItemCount(id, false);
  local text = addon:stringJoin({'(', bagCount, ')'}, '');

  Print.printItem(texture, name, count, text, colors);
end

local function printStackableItemTotalAndBags (id, texture, name, count, colors)
  local bagCount = getFormattedItemCount(id, false);
  local totalCount = getFormattedItemCount(id, true);
  local text = addon:stringJoin({'(', bagCount, '/', totalCount, ')'}, '');

  Print.printItem(texture, name, count, text, colors);
end

local function printItemIncludingTotal (id, texture, name, count, colors)
  if (addon.savedVariables.farmerOptions.showBags == true) then
    printStackableItemTotalAndBags(id, texture, name, count, colors);
  else
    printStackableItemTotal(id, texture, name, count, colors);
  end
end

local function printItemExcludingTotal (id, texture, name, count, colors)
  if (addon.savedVariables.farmerOptions.showBags == true) then
    printStackableItemBags(id, texture, name, count, colors);
  else
    Print.printItem(texture, name, count, nil, colors)
  end
end

function Print.checkHideOptions ()
  if (addon.savedVariables.farmerOptions.hideAtMailbox == true and
      mailIsOpen) then
    return false;
  end

  if (addon.savedVariables.farmerOptions.hideOnExpeditions == true and
      -- cannot be deferred earlier, as this frame gets initialized dynamically
      _G.IslandsPartyPoseFrame and
      _G.IslandsPartyPoseFrame:IsShown()) then
    return false;
  end

  if (addon.savedVariables.farmerOptions.hideInArena == true and
      IsActiveBattlefieldArena and
      IsActiveBattlefieldArena()) then
    return false;
  end

  return true;
end

function Print.printMessage (message, colors)
  colors = colors or {1, 1, 1};

  farmerFrame:AddMessage(message, unpack(colors, 1, 3));
end

function Print.printItem (texture, name, count, text, colors, options)
  count = count or 1;
  options = options or {};

  local icon = addon:getIcon(texture);
  local itemName;
  local itemCount;
  local message;

  if (not options.minimumCount or count > options.minimumCount) then
    itemCount = 'x' .. BreakUpLargeNumbers(count);
  end

  if (addon.savedVariables.farmerOptions.itemNames == true or
      options.forceName == true) then
    itemName = name;
  end

  message = addon:stringJoin({itemName, itemCount, text}, ' ');

  if (message == '') then
    message = name;
  end

  Print.printMessage(icon .. ' ' .. message, colors);
end

function Print.printStackableItem (id, texture, name, count, colors)
  if (addon.savedVariables.farmerOptions.showTotal == true) then
    printItemIncludingTotal(id, texture, name, count, colors);
  else
    printItemExcludingTotal(id, texture, name, count, colors);
  end
end

function Print.printEquip (texture, name, text, count, colors)
  if (text and text ~= '') then
    text = '[' .. text .. ']';
  end

  Print.printItem(texture, name, count, text, colors, {minimumCount = 1});
end

