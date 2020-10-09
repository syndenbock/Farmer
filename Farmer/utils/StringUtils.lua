local _, addon = ...;

local strfind = _G.strfind;
local strsub = _G.strsub;
local strmatch = _G.strmatch;
local tinsert = _G.tinsert;
local floor = _G.floor;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local COPPER_PER_GOLD = _G.COPPER_PER_GOLD;
local COPPER_PER_SILVER = _G.COPPER_PER_SILVER;
local SILVER_PER_GOLD = _G.SILVER_PER_GOLD;

local addonVars = addon.share('vars');

function addon.stringStartsWith (string, check)
  return (string:sub(1, #check) == check);
end

function addon.stringEndsWith (string, check)
  return (check == "" or string:sub(-#check) == check);
end

function addon.stringJoin (stringList, joiner)
  joiner = joiner or '';
  local result;

  for _, fragment in pairs(stringList) do
    if (fragment) then
      result = result and result .. joiner .. fragment or fragment;
    end
  end

  return result or '';
end

function addon.replaceString (string, match, replacement)
  local startPos, endPos = strfind(string, match, 1, true);

  if (startPos) then
    return strsub(string, 1, startPos - 1) .. replacement .. strsub(string, endPos + 1);
  else
    return string;
  end
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
