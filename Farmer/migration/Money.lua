local _, addon = ...;

local Migrate = addon.Migration;

Migrate.addMigration('3.1', function (variables)
  Migrate.migrateOptionsToSubobject(variables.farmerOptions, 'Money', {
    money = 'displayMoney',
  });
end);

Migrate.addMigration('3.5', function (variables)
  local earningStamp = _G.earningStamp;
  local characterOptions = variables.farmerCharOptions or {};
  local characterMoneyOptions = characterOptions.Money or {};

  if (type(earningStamp) == 'number' and not characterMoneyOptions.earningStamp) then
    characterMoneyOptions.earningStamp = earningStamp;
    characterOptions.Money = characterMoneyOptions;
    variables.characterOptions = characterOptions;
  end
end);
