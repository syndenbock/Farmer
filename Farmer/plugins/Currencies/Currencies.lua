local addonName, addon = ...;

if (addon.isClassic()) then return end

local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;

local checkHideOptions = addon.Print.checkHideOptions;
local printItemMessage = addon.Print.printItemMessage;

local ACCOUNT_HONOR_ID = 1585;
local HONOR_ID = 1792;
local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Currency;

local function checkDisplayOptions (id)
  if (options.displayCurrencies == false) then
    return false;
  end

  if (options.ignoreHonor == true and
      (id == ACCOUNT_HONOR_ID or id == HONOR_ID)) then
    return false;
  end

  return true;
end

local function shouldCurrencyBeDisplayed (info, amount)
  return (amount > 0 and
          checkDisplayOptions(info.id) and
          checkHideOptions());
end

local function displayCurrency (info, amount)
  -- warfronts show hidden currencies without icons
  if (not info.name or not info.icon) then return end

  local text = 'x' .. amount .. ' ' ..
      '(' .. BreakUpLargeNumbers(info.total) .. ')';

  printItemMessage({
    texture = info.icon,
    name = info.name,
  },  text, {1, 0.9, 0, 1});
end

addon.listen('CURRENCY_CHANGED', function (info, amount)
  if (not shouldCurrencyBeDisplayed(info, amount)) then return end

  displayCurrency(info, amount);
end);
