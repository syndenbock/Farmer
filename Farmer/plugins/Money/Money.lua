local addonName, addon = ...;

if (not addon.isDetectorAvailable('money')) then return end

local checkHideOptions = addon.Print.checkHideOptions;
local printMessageWithData = addon.Print.printMessageWithData;

local farmerFrame = addon.frame;

local MESSAGE_COLORS = {r = 1, g = 1, b = 1};
local SUBSPACE = farmerFrame:CreateSubspace();
local IDENTIFIER = 'money';

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Money;

local function shouldMoneyBeDisplayed (amount)
  return (amount > 0 and
          options.displayMoney == true and
          checkHideOptions());
end

local function displayMoney (amount)
  amount = amount + (farmerFrame:GetMessageData(SUBSPACE, IDENTIFIER) or 0);
  printMessageWithData(SUBSPACE, IDENTIFIER, amount, addon.formatMoney(amount),
      MESSAGE_COLORS);
end

addon.listen('MONEY_CHANGED', function (amount)
  if (shouldMoneyBeDisplayed(amount)) then
    displayMoney(amount);
  end
end);
