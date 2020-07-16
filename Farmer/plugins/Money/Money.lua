local addonName, addon = ...;

local checkHideOptions = addon.Print.checkHideOptions;

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

local function shouldMoneyBeDisplayed (amount)
  return (amount > 0 and
          saved.farmerOptions.money == true and
          checkHideOptions());
end

local function displayMoney (amount)
  addon.Print.printMessage(addon.formatMoney(amount), {1, 1, 1});
end

addon.listen('MONEY_CHANGED', function (amount)
  if (shouldMoneyBeDisplayed(amount)) then
    displayMoney(amount);
  end
end);
