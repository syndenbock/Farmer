local addonName, addon = ...;

if (not addon.isDetectorAvailable('currencies')) then return end

local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;

local stringJoin = addon.stringJoin;
local checkHideOptions = addon.Print.checkHideOptions;
local printIconMessageWithData = addon.Print.printIconMessageWithData;
local getRarityColor = addon.getRarityColor;

local farmerFrame = addon.frame;

local ACCOUNT_HONOR_ID = 1585;
local HONOR_ID = 1792;
local ADDON_OPTIONS = addon.SavedVariablesHandler(addonName, 'farmerOptions')
    .vars.farmerOptions;
local CORE_OPTIONS = ADDON_OPTIONS.Core;
local CURRENCY_OPTIONS = ADDON_OPTIONS.Currency;
local SUBSPACE = farmerFrame:CreateSubspace();

local function checkDisplayOptions (id)
  -- ignore bonus valor
  if (id == 1947) then
    return false;
  end

  if (CURRENCY_OPTIONS.displayCurrencies == false) then
    return false;
  end

  if (CURRENCY_OPTIONS.ignoreHonor == true and
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

  local text;

  amount = (farmerFrame:GetMessageData(SUBSPACE, info.id) or 0) + amount;
  text = stringJoin({'x' .. BreakUpLargeNumbers(amount), ' ', '(',
      BreakUpLargeNumbers(info.total), ')'}, '');

  if (CORE_OPTIONS.itemNames == true) then
    text = info.name .. ' ' .. text;
  end

  printIconMessageWithData(SUBSPACE, info.id, amount, info.icon, text,
      getRarityColor(info.rarity));
end

addon.listen('CURRENCY_CHANGED', function (info, amount)
  if (not shouldCurrencyBeDisplayed(info, amount)) then return end

  displayCurrency(info, amount);
end);
