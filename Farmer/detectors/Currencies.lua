local addonName, addon = ...;

if (addon:isClassic()) then return end

local HONOR_ID = 1585;
local CONQUEST_ID = 1602;

do
  --[[ trying to read global constants --]]
  local constant = _G['Constant'];

  if (constant ~= nil) then
    local currency = constant.Currency;

    if (currency ~= nil) then
      HONOR_ID = currency.Honor or HONOR_ID;
      CONQUEST_ID = currency.Conquest or CONQUEST_ID;
    end
  end
end

local currencyTable;

local function getCurrencyAmount (currencyId)
  local info = {GetCurrencyInfo(currencyId)};

  return info[2];
end

local function fillCurrencyTable ()
  local data = {};
  local expandedIndices = {};
  local listSize = GetCurrencyListSize();
  local i = 1;
  local expandCount = 0;

  while (i <= listSize) do
    local info = {GetCurrencyListInfo(i)};
    local isHeader = info[2];
    local isExpanded = info[3];

    if (isHeader) then
      if (not isExpanded) then
        expandCount = expandCount + 1;
        expandedIndices[expandCount] = i;
        ExpandCurrencyList(i, 1);
        listSize = GetCurrencyListSize();
      end
    else
      local link = GetCurrencyListLink(i);
      local id = C_CurrencyInfo.GetCurrencyIDFromLink(link);
      local count = info[6];

      data[id] = count;
    end

    i = i + 1;
  end

  --[[ the headers have to be collapse from bottom to top, because collapsing
       top ones first would change the index of the lower ones  --]]
  for i = #expandedIndices, 1, -1 do
    ExpandCurrencyList(expandedIndices[i], 0);
  end

  data[HONOR_ID] = getCurrencyAmount(HONOR_ID);
  data[CONQUEST_ID] = getCurrencyAmount(CONQUEST_ID);

  currencyTable = data;
end

local function handleCurrency (id, total)
  local amount = total - (currencyTable[id] or 0);

  currencyTable[id] = total;

  addon:yell('CURRENCY_CHANGED', id, amount, total);
end

addon:on('PLAYER_LOGIN', fillCurrencyTable);

-- amount is always positive so we cannot use it
addon:on('CURRENCY_DISPLAY_UPDATE', function (id, total, amount)
  if (currencyTable == nil) then
    return;
  end

  if (id == nil) then return end

  handleCurrency(id, total);
end);
