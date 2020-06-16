local addonName, addon = ...;

if (addon:isClassic()) then return end

local HONOR_ID = 1585;
local CONQUEST_ID = 1602;
local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

local function checkCurrencyDisplay (id)
  if (saved.farmerOptions.currency == false) then
    return false;
  end

  if (saved.farmerOptions.ignoreHonor == true) then
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
  if (not name or not texture) then return end

  local text = '(' .. BreakUpLargeNumbers(total) .. ')';

  addon.Print.printItem(texture, name, amount, text, {1, 0.9, 0, 1});
end);
