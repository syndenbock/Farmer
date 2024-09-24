local addonName, addon = ...;

if (not addon.isDetectorAvailable('money')) then return end

local Yell = addon.import('core/logic/Yell');
local Strings = addon.import('core/utils/Strings');
local SavedVariables = addon.import('client/utils/SavedVariables');
local Main = addon.import('main/Main');
local Print = addon.import('main/Print');

local checkHideOptions = Print.checkHideOptions;
local printMessageWithData = Print.printMessageWithData;

local MESSAGE_COLORS = {r = 1, g = 1, b = 1};
local SUBSPACE = Main.frame:CreateSubspace();
local IDENTIFIER = 'money';

local options =
    SavedVariables.SavedVariablesHandler(addonName, 'farmerOptions').vars.farmerOptions.Money;

local function shouldMoneyBeDisplayed (amount)
  return (amount > 0 and
          options.displayMoney == true and
          checkHideOptions());
end

local function displayMoney (amount)
  amount = amount + (Main.frame:GetMessageData(SUBSPACE, IDENTIFIER) or 0);
  printMessageWithData(SUBSPACE, IDENTIFIER, amount, Strings.formatMoney(amount), MESSAGE_COLORS);
end

Yell.listen('MONEY_CHANGED', function (amount)
  if (shouldMoneyBeDisplayed(amount)) then
    displayMoney(amount);
  end
end);
