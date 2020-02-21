local addonName, addon = ...;

local HONOR_ID = 1585;
local CONQUEST_ID = 1602;

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

addon:listen('CURRENCY_CHANGED', function (id, amount, total)
  if (amount <= 0 or
      checkCurrencyDisplay(id) == false or
      addon.Print.checkHideOptions() == false) then
    return;
  end

  local info = {GetCurrencyInfo(id)};
  local name = info[1];
  local texture = info[3];

  -- warfronts show hidden currencies without icons
  if (name == nil or texture == nil) then return end

  if (info[2] ~= total) then
    print('currency totals are different');
  end

  local text = '(' .. total .. ')';

  addon.Print.printItem(texture, name, amount, text, {1, 0.9, 0, 1});
end);
