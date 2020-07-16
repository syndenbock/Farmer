local _, addon = ...;

if (addon.isClassic()) then return end

local tinsert = _G.tinsert;
local GetCurrencyInfo = _G.GetCurrencyInfo;
local GetCurrencyListSize = _G.GetCurrencyListSize;
local GetCurrencyListInfo = _G.GetCurrencyListInfo;
local GetCurrencyListLink = _G.GetCurrencyListLink;
local ExpandCurrencyList = _G.ExpandCurrencyList;
local GetCurrencyIDFromLink = _G.C_CurrencyInfo.GetCurrencyIDFromLink;

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
  local info = {GetCurrencyInfo(currencyId)};

  return info[2];
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
    local info = {GetCurrencyListInfo(i)};
    local isHeader = info[2];
    local isExpanded = info[3];

    if (isHeader) then
      if (not isExpanded) then
        tinsert(expandedIndices, i);
        ExpandCurrencyList(i, 1);
        listSize = GetCurrencyListSize();
      end
    else
      local link = GetCurrencyListLink(i);
      local id = GetCurrencyIDFromLink(link);
      local count = info[6];

      data[id] = count;
    end

    i = i + 1;
  end

  collapseExpandedCurrencies(expandedIndices);

  data[HONOR_ID] = getCurrencyAmount(HONOR_ID);
  data[CONQUEST_ID] = getCurrencyAmount(CONQUEST_ID);

  currencyTable = data;
end

local function yellCurrency (id, amount, total)
  addon.yell('CURRENCY_CHANGED', id, amount, total);
end

local function handleCurrency (id, total)
  local amount = total - (currencyTable[id] or 0);

  currencyTable[id] = total;
  yellCurrency(id, amount, total);
end

addon.on('PLAYER_LOGIN', fillCurrencyTable);

-- amount passed by the event is always positive so we cannot use it
addon.on('CURRENCY_DISPLAY_UPDATE', function (id, total)
  if (not currencyTable or not id) then return end

  handleCurrency(id, total);
end);

--##############################################################################
-- testing
--##############################################################################

local tests = addon:share('tests');

function tests.currency ()
  yellCurrency(1755, 1500, 15357);
end
