local addonName, addon = ...;

local floor = _G.floor;
local log10 = _G.log10;
local strmatch = _G.strmatch;
local tinsert = _G.tinsert;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local WOW_PROJECT_ID = _G.WOW_PROJECT_ID;
local WOW_PROJECT_CLASSIC = _G.WOW_PROJECT_CLASSIC;
local COPPER_PER_GOLD = _G.COPPER_PER_GOLD;
local COPPER_PER_SILVER = _G.COPPER_PER_SILVER;
local SILVER_PER_GOLD = _G.SILVER_PER_GOLD;

local addonVars = addon.share('vars');

function addon.isClassic ()
  return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC;
end

function addon.round (number)
  return floor(number + 0.5);
end

function addon.toStepPrecision (value, stepSize)
  if (stepSize == 1) then
    return addon.round(value);
  end

  return addon.round(value / stepSize) * stepSize;
end

function addon.stepSizeToPrecision (stepSize)
  if (stepSize == 1) then
    return 0;
  end

  -- step sizes received from sliders are slightly off the actual value, so
  -- round has to be used
  return addon.round(log10(1 / stepSize));
end

function addon.truncate (number, digits)
  if (digits == 0) then
    return addon.round(number);
  end

  local factor = 10 ^ digits;

  number = number * factor;
  number = addon.round(number);
  number = number / factor;

  return number;
end

local function formatMoney (amount, icons)
  local gold = floor(amount / COPPER_PER_GOLD);
  local silver = floor(amount / COPPER_PER_SILVER) % SILVER_PER_GOLD;
  local copper = amount % COPPER_PER_SILVER;
  local text = {};

  if (gold > 0) then
    tinsert(text, BreakUpLargeNumbers(gold) .. icons.gold);
  end

  if (silver > 0) then
    tinsert(text, BreakUpLargeNumbers(silver) .. icons.silver);
  end

  if (copper > 0 or #text == 0) then
    tinsert(text, BreakUpLargeNumbers(copper) .. icons.copper);
  end

  return addon.stringJoin(text, ' ');
end

function addon.formatMoneyWithOffset (amount)
  return formatMoney (amount, {
    gold = addon.getIcon('Interface\\MoneyFrame\\UI-GoldIcon'),
    silver = addon.getIcon('Interface\\MoneyFrame\\UI-SilverIcon'),
    copper = addon.getIcon('Interface\\MoneyFrame\\UI-CopperIcon'),
  });
end

function addon.formatMoney (amount)
  return formatMoney (amount, {
    gold = '|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:0:0|t',
    silver = '|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:0:0|t',
    copper = '|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:0:0|t',
  });
end

function addon.getIcon (texture)
  return addon.stringJoin({'|T', texture, addonVars.iconOffset, '|t'}, '');
end

function addon.findItemLink (string)
  return strmatch(string, '|c.+|h|r');
end

function addon.extractItemString (itemLink)
  return strmatch(itemLink, 'item[%-?%d:]+') or itemLink;
end

function addon.setTrueScale (frame, scale)
  frame:SetScale(1);
  frame:SetScale(scale / frame:GetEffectiveScale());
end

function addon.printTable (table)
  if (type(table) ~= 'table') then
    print(table);
    return;
  end

  if (not next(table)) then
    print('table is empty');
    return;
  end

  for i,v in pairs(table) do
    print(i, ' - ', v);
  end
end

function addon.secureCall (callback, ...)
  local success, message = pcall(callback, ...);

  if (not success) then
    print('error in', addonName, 'plugin:', message);
  end
end
