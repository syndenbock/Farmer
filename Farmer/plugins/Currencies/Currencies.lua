local addonName, addon = ...;

if (not addon.isDetectorAvailable('currencies')) then return end

local strjoin = _G.strjoin;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;

local checkHideOptions = addon.Print.checkHideOptions;
local printIconMessageWithData = addon.Print.printIconMessageWithData;
local getRarityColor = addon.getRarityColor;

local farmerFrame = addon.frame;

local ACCOUNT_HONOR_ID = 1585;
local HONOR_ID = 1792;

local RARITY_GRAY = _G.Enum.ItemQuality.Poor;

local ADDON_OPTIONS = addon.SavedVariablesHandler(addonName, 'farmerOptions')
    .vars.farmerOptions;
local CORE_OPTIONS = ADDON_OPTIONS.Core;
local CURRENCY_OPTIONS = ADDON_OPTIONS.Currency;
local SUBSPACE = farmerFrame:CreateSubspace();

local IGNORED_CURRENCIES = {
  [1822] = true, -- Renown
  [1947] = true, -- Bonus Valor
  [2408] = true, -- Bonus Flightstones
};

local function isCurrencyIgnored (currency)
  return (IGNORED_CURRENCIES[currency] == true);
end

local function checkDisplayOptions (info)
  if (CURRENCY_OPTIONS.displayCurrencies == false) then
    return false;
  end

  if (info.quality <= RARITY_GRAY) then
    return false;
  end

  if (isCurrencyIgnored(info.id)) then
    return false;
  end

  if (CURRENCY_OPTIONS.ignoreHonor == true and
      (info.id == ACCOUNT_HONOR_ID or info.id == HONOR_ID)) then
    return false;
  end

  return true;
end

local function shouldCurrencyBeDisplayed (info, amount)
  return (amount > 0 and
          checkDisplayOptions(info) and
          checkHideOptions());
end

local function displayCurrency (info, amount)
  -- warfronts show hidden currencies without icons
  if (not info.name or not info.iconFileID) then return end

  local text;

  amount = (farmerFrame:GetMessageData(SUBSPACE, info.id) or 0) + amount;
  text = strjoin('',
    'x', BreakUpLargeNumbers(amount),
    ' (', BreakUpLargeNumbers(info.quantity), ')'
  );

  if (CORE_OPTIONS.itemNames == true) then
    text = info.name .. ' ' .. text;
  end

  printIconMessageWithData(SUBSPACE, info.id, amount, info.iconFileID, text,
      getRarityColor(info.quality));
end

addon.listen('CURRENCY_CHANGED', function (info, amount)
  if (not shouldCurrencyBeDisplayed(info, amount)) then return end

  displayCurrency(info, amount);
end);
