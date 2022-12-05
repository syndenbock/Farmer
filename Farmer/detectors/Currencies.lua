local _, addon = ...;

if (addon.findGlobal('C_CurrencyInfo', 'GetCurrencyListInfo') == nil) then
  addon.registerUnavailableDetector('currencies');
  return;
end

addon.registerAvailableDetector('currencies');

local tinsert = _G.tinsert;
local C_CurrencyInfo = _G.C_CurrencyInfo;
local ExpandCurrencyList = C_CurrencyInfo.ExpandCurrencyList;
local GetCurrencyIDFromLink = C_CurrencyInfo.GetCurrencyIDFromLink;
local GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo;
local GetCurrencyListInfo = C_CurrencyInfo.GetCurrencyListInfo;
local GetCurrencyListLink = C_CurrencyInfo.GetCurrencyListLink;
local GetCurrencyListSize = C_CurrencyInfo.GetCurrencyListSize;

local ImmutableMap = addon.import('Factory/ImmutableMap');

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
    ExpandCurrencyList(expandedIndices[x], false);
  end
end

local function readCurrencyTable ()
  local data = {};
  local expandedIndices = {};
  local listSize = GetCurrencyListSize();
  local index = 1;

  while (index <= listSize) do
    local info = GetCurrencyListInfo(index);

    if (info == nil) then
      addon.printAddonMessage('Could not check currencies as another addon seems to be interfering with the currency pane');
      break;
    end

    if (info.isHeader) then
      if (not info.isHeaderExpanded) then
        tinsert(expandedIndices, index);
        ExpandCurrencyList(index, true);
        listSize = GetCurrencyListSize();
      end
    else
      local link = GetCurrencyListLink(index);
      local id = GetCurrencyIDFromLink(link);
      local count = info.quantity;

      data[id] = count;
    end

    index = index + 1;
  end

  collapseExpandedCurrencies(expandedIndices);

  data[HONOR_ID] = getCurrencyAmount(HONOR_ID);
  data[CONQUEST_ID] = getCurrencyAmount(CONQUEST_ID);

  return data;
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

-- quantities passed by the event can be factorized or negative so they cannot
-- be used
local function handleCurrency (_, id)
  if (id == nil) then return end

  local info = packCurrencyInfo(id);
  local amount = info.total - (currencyTable[id] or 0);

  currencyTable[id] = info.total;
  yellCurrencyInfo(info, amount);
end

addon.onOnce('PLAYER_LOGIN', function ()
  currencyTable = readCurrencyTable();
  addon.on('CURRENCY_DISPLAY_UPDATE', handleCurrency);
end);

--##############################################################################
-- testing
--##############################################################################

addon.import('tests').currency = function ()
  yellCurrencyInfo(packCurrencyInfo(1755), 15357);
end;
