local addonName, addon = ...;

if (not addon.isDetectorAvailable('currencies')) then return end

local strconcat = _G.strconcat;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;

local Yell = addon.import('core/logic/Yell');
local SavedVariables = addon.import('client/utils/SavedVariables');
local getRarityColor = addon.import('client/utils/Items').getRarityColor;
local Main = addon.import('main/Main');
local Print = addon.import('main/Print');

local checkHideOptions = Print.checkHideOptions;
local printIconMessageWithData = Print.printIconMessageWithData;

local ACCOUNT_HONOR_ID = 1585;
local HONOR_ID = 1792;

local RARITY_GRAY = _G.Enum.ItemQuality.Poor;

local ADDON_OPTIONS =
    SavedVariables.SavedVariablesHandler(addonName, 'farmerOptions').vars.farmerOptions;
local CORE_OPTIONS = ADDON_OPTIONS.Core;
local CURRENCY_OPTIONS = ADDON_OPTIONS.Currency;
local SUBSPACE = Main.frame:CreateSubspace();

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

  amount = (Main.frame:GetMessageData(SUBSPACE, info.id) or 0) + amount;
  text = strconcat(
    'x', BreakUpLargeNumbers(amount),
    ' (', BreakUpLargeNumbers(info.quantity), ')'
  );

  if (CORE_OPTIONS.itemNames == true) then
    text = info.name .. ' ' .. text;
  end

  printIconMessageWithData(SUBSPACE, info.id, amount, info.iconFileID, text,
      getRarityColor(info.quality));
end

Yell.listen('CURRENCY_CHANGED', function (info, amount)
  if (not shouldCurrencyBeDisplayed(info, amount)) then return end

  displayCurrency(info, amount);
end);
