local addonName, addon = ...;

if (addon.isClassic()) then return end

local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;

local checkHideOptions = addon.Print.checkHideOptions;

local HONOR_ID = 1585;
local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Currency;

local function checkDisplayOptions (id)
  if (options.displayCurrencies == false) then
    return false;
  end

  if (options.ignoreHonor == true and id == HONOR_ID) then
    return false;
  end

  return true;
end

local function shouldCurrencyBeDisplayed (info, amount)
  return (amount >= 0 and
          checkDisplayOptions(info.id) and
          checkHideOptions());
end

local function displayCurrency (info, amount)
  -- warfronts show hidden currencies without icons
  if (not info.name or not info.icon) then return end

  local text = '(' .. BreakUpLargeNumbers(info.total) .. ')';

  addon.Print.printItem(info.icon, info.name, amount, text, {1, 0.9, 0, 1});
end

addon.listen('CURRENCY_CHANGED', function (info, amount)
  if (not shouldCurrencyBeDisplayed(info, amount)) then return end

  displayCurrency(info, amount);
end);
