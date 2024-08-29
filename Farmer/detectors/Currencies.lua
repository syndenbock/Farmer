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

local Currency = addon.findGlobal('Constant', 'Currency');

local ImmutableMap = addon.import('Factory/ImmutableMap');

local HONOR_ID = Currency and Currency.Honor or 1585;
local CONQUEST_ID = Currency and Currency.Conquest or 1602;

local currencyTable;

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
      addon.printOneTimeMessage('Could not check currencies as another addon seems to be interfering with the currency pane');
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

local function yellCurrencyInfo (id, info, change)
  -- CurrencyInfo doesn't contain the id for some reason
  info.id = id;
  addon.yell('CURRENCY_CHANGED', ImmutableMap(info), change);
end

-- quantities passed by the event can be factorized or negative so they cannot
-- be used
local function handleCurrency (_, id)
  if (id == nil) then return end

  local info = GetCurrencyInfo(id);
  local amount = info.quantity - (currencyTable[id] or 0);

  currencyTable[id] = info.quantity;
  yellCurrencyInfo(id, info, amount);
end

addon.onOnce('FIRST_FRAME_RENDERED', function ()
  currencyTable = readCurrencyTable();
  addon.on('CURRENCY_DISPLAY_UPDATE', handleCurrency);
end);

--##############################################################################
-- testing
--##############################################################################

addon.import('tests').currency = function ()
  yellCurrencyInfo(1755, GetCurrencyInfo(1755), 15357);
end;
