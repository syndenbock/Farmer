local addonName, addon = ...;

local checkHideOptions = addon.Print.checkHideOptions;
local printMessage = addon.Print.printMessage;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Money;

local function shouldMoneyBeDisplayed (amount)
  return (amount > 0 and
          options.displayMoney == true and
          checkHideOptions());
end

local function displayMoney (amount)
  printMessage(addon.formatMoney(amount), {1, 1, 1});
end

addon.listen('MONEY_CHANGED', function (amount)
  if (shouldMoneyBeDisplayed(amount)) then
    displayMoney(amount);
  end
end);

addon.share('tests').money = function ()
  displayMoney(12390);
end
