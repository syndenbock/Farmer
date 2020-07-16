local _, addon = ...;

local floor = _G.floor;
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

function addon.formatMoney (money)
  local ICON_GOLD = '|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:0:0|t';
  local ICON_SILVER = '|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:0:0|t';
  local ICON_COPPER = '|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:0:0|t';

  local gold = floor(money / COPPER_PER_GOLD);
  local silver = floor(money / COPPER_PER_SILVER) % SILVER_PER_GOLD;
  local copper = money % COPPER_PER_SILVER;
  local text = {};

  if (gold > 0) then
    table.insert(text, BreakUpLargeNumbers(gold) .. ICON_GOLD);
  end

  if (silver > 0) then
    table.insert(text, BreakUpLargeNumbers(silver) .. ICON_SILVER);
  end

  if (copper > 0 or #text == 0) then
    table.insert(text, BreakUpLargeNumbers(copper) .. ICON_COPPER);
  end

  return addon.stringJoin(text, ' ');
end

function addon.getIcon (texture)
  return addon.stringJoin({'|T', texture, addonVars.iconOffset, '|t'}, '');
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
