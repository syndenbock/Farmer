local _, addon = ...;

local Migrate = addon.Migration;

Migrate.addMigration('3.1', function (variables)
  local farmerOptions = variables.farmerOptions;

  if (farmerOptions == nil) then return end

  local currency = farmerOptions.currency;
  local ignoreHonor = farmerOptions.ignoreHonor;
  local Currency = farmerOptions.Currency or {};

  farmerOptions.Currency = Currency;

  if (currency ~= nil) then
    farmerOptions.currency = nil;
    Currency.displayCurrencies = currency;
  end

  if (ignoreHonor ~= nil) then
    farmerOptions.ignoreHonor = nil;
    Currency.ignoreHonor = ignoreHonor;
  end
end);
