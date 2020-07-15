local addonName, addon = ...;

if (addon:isClassic()) then return end

local GetCurrencyInfo = _G.GetCurrencyInfo;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;

local checkHideOptions = addon.Print.checkHideOptions;

local HONOR_ID = 1585;
local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

local function checkDisplayOptions (id)
  if (saved.farmerOptions.currency == false) then
    return false;
  end

  if (saved.farmerOptions.ignoreHonor == true and id == HONOR_ID) then
    return false;
  end

  return true;
end

local function shouldCurrencyBeDisplayed (id, amount)
  return (amount >= 0 and
      checkDisplayOptions(id) and
      checkHideOptions());
end

local function displayCurrency (id, amount, total)
  local info = {GetCurrencyInfo(id)};
  local name = info[1];
  local texture = info[3];

  -- warfronts show hidden currencies without icons
  if (not name or not texture) then return end

  local text = '(' .. BreakUpLargeNumbers(total) .. ')';

  addon.Print.printItem(texture, name, amount, text, {1, 0.9, 0, 1});
end

addon:listen('CURRENCY_CHANGED', function (id, amount, total)
  if (not shouldCurrencyBeDisplayed(id, amount)) then return end

  displayCurrency(id, amount, total);
end);
