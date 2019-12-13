local addonName, addon = ...;

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

local currencyTable = {};

local function getCurrencyAmount (currencyId)
  local info = {GetCurrencyInfo(currencyId)};

  return info[2];
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
        expandedIndices[#expandedIndices + 1] = i;
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

local function checkCurrencyDisplay (id)
  if (farmerOptions.currency == false) then
    return false;
  end

  if (farmerOptions.ignoreHonor == true) then
    if (id == HONOR_ID) then
      return false;
    end
  end

  return true;
end

local function handleCurrency (id)
  local info = {GetCurrencyInfo(id)};
  local total = info[2];
  local texture = info[3];

  -- warfronts show hidden currencies without icons
  if (total == nil or texture == nil) then return end

  local name = info[1];
  local amount = currencyTable[id] or 0;

  currencyTable[id] = total;
  amount = total - amount;

  if (amount <= 0) then return end

  local text = '(' .. total .. ')';

  addon.Print.printItem(texture, name, amount, text, {1, 0.9, 0, 1});
end

addon:on('PLAYER_LOGIN', function ()
  fillCurrencyTable();
end);

addon:on('CURRENCY_DISPLAY_UPDATE', function (id, total, amount)
  if (id == nil) then return end

  if (checkCurrencyDisplay(id) == false or
      addon.Print.checkHideOptions() == false) then
    currencyTable[id] = total;
    return;
  end

  handleCurrency(id);
end);
