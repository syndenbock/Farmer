local _, addon = ...;

local Migrate = addon.Migration;

Migrate.addMigration('3.1', function (variables)
  Migrate.migrateOptionsToSubobject(variables.farmerOptions, 'Currency', {
    currency = 'displayCurrencies',
    ignoreHonor = 'ignoreHonor',
  });
end);
