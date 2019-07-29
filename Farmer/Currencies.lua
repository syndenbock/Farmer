local addonName, addon = ...;

local currencyTable = {};

local function fillCurrencyTable()
  -- a pretty ugly workaround, but WoW has no table containing the currency ids
  -- does not take long though, so it's fine (2ms on my shitty ass pc)
  for i = 1, 2000 do
    local info = {GetCurrencyInfo(i)};

    if (info[2]) then
      currencyTable[i] = info[2];
    end
  end
end

local function checkCurrencyDisplay (id)
  if (farmerOptions.ignoreHonor == true) then
    local honorId = 1585;

    if (id == honorId) then
      return false;
    end
  end

  return true;
end

local function handleCurrency (id)
  local name, total, texture, earnedThisWeek, weeklyMax, totalMax, isDicovered,
  rarity = GetCurrencyInfo(id)
  local amount = currencyTable[id] or 0

  amount = total - amount

  -- warfronts show unknown currencies
  if (name == nil or texture == nil) then return end

  currencyTable[id] = total;

  if (checkCurrencyDisplay(id) == false or
      addon.Print.checkHideOptions() == false) then return end

  if (amount <= 0) then return end

  local text = 'x' .. amount .. ' (' .. total .. ')';

  addon.Print.printItem(texture, name, text, {1, 0.9, 0, 1});
end

addon:on('PLAYER_LOGIN', function ()
  fillCurrencyTable();
end);

addon:on('CURRENCY_DISPLAY_UPDATE', function (id, total, amount)
  if (id == nil) then return end

  handleCurrency(id);
end);
