local _, addon = ...;

if (addon.isClassic()) then return end

local tinsert = _G.tinsert;
local C_CurrencyInfo = _G.C_CurrencyInfo;
local ExpandCurrencyList = C_CurrencyInfo.ExpandCurrencyList;
local GetCurrencyIDFromLink = C_CurrencyInfo.GetCurrencyIDFromLink;
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
local GetCurrencyListInfo = C_CurrencyInfo.GetCurrencyListInfo;
local GetCurrencyListLink = C_CurrencyInfo.GetCurrencyListLink;
local GetCurrencyListSize = C_CurrencyInfo.GetCurrencyListSize;

local ImmutableMap = addon.Factory.ImmutableMap;

local HONOR_ID = 1585;
local CONQUEST_ID = 1602;

local currencyTable;

local function tryToReadGlobalConstants ()
  --[[ trying to read global constants --]]
  local constant = _G['Constant'];
  local currency = constant and constant.Currency;

  if (not currency) then return end

  HONOR_ID = currency.Honor or HONOR_ID;
  CONQUEST_ID = currency.Conquest or CONQUEST_ID;
end

tryToReadGlobalConstants();

local function getCurrencyAmount (currencyId)
  return GetCurrencyInfo(currencyId).quantity;
end

local function collapseExpandedCurrencies (expandedIndices)
  --[[ the headers have to be collapsed from bottom to top, because collapsing
       top ones first would change the index of the lower ones  --]]
  for x = #expandedIndices, 1, -1 do
    ExpandCurrencyList(expandedIndices[x], 0);
  end
end

local function fillCurrencyTable ()
  local data = {};
  local expandedIndices = {};
  local listSize = GetCurrencyListSize();
  local i = 1;

  while (i <= listSize) do
    local info = GetCurrencyListInfo(i);

    if (info.isHeader) then
      if (not info.isExpanded) then
        tinsert(expandedIndices, i);
        ExpandCurrencyList(i, 1);
        listSize = GetCurrencyListSize();
      end
    else
      local link = GetCurrencyListLink(i);
      local id = GetCurrencyIDFromLink(link);
      local count = info.quantity;

      data[id] = count;
    end

    i = i + 1;
  end

  collapseExpandedCurrencies(expandedIndices);

  data[HONOR_ID] = getCurrencyAmount(HONOR_ID);
  data[CONQUEST_ID] = getCurrencyAmount(CONQUEST_ID);

  currencyTable = data;
end

local function packCurrencyInfo (id)
  local info = GetCurrencyInfo(id);

  return {
    id = id,
    name = info.name,
    total = info.quantity,
    icon = info.iconFileID,
    earnedThisWeek = info.quantityEarnedThisWeek,
    weeklyMax = info.maxWeeklyQuantity,
    totalMax = info.maxQuantity,
    isDiscovered = info.discovered,
    rarity = info.quality,
  };
end

local function yellCurrencyInfo (info, change)
  addon.yell('CURRENCY_CHANGED', ImmutableMap(info), change);
end

local function handleCurrency (id)
  local info = packCurrencyInfo(id);
  local amount = info.total - (currencyTable[id] or 0);

  currencyTable[id] = info.total;
  yellCurrencyInfo(info, amount);
end

addon.on('PLAYER_LOGIN', fillCurrencyTable);

-- quantities passed by the event can be factorized or negative so they cannot
-- be used
addon.funnel('CURRENCY_DISPLAY_UPDATE', function (paramCollection)
  if (not currencyTable) then return end

  local idMap = {};

  for _, paramList in ipairs(paramCollection) do
    local id = paramList[1];

    if (id) then
      idMap[id] = true;
    end
  end

  for id in pairs(idMap) do
    handleCurrency(id);
  end
end);

--##############################################################################
-- testing
--##############################################################################

addon.share('tests').currency = function ()
  yellCurrencyInfo(packCurrencyInfo(1755), 15357);
end
