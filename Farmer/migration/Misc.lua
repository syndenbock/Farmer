local _, addon = ...;

local Migrate = addon.import('core/logic/Migration');

Migrate.addMigration('3.1', function (variables)
  Migrate.migrateOptionsToSubobject(variables.farmerOptions, 'Misc', {
    fastLoot = 'fastLoot',
    hidePlatesWhenFishing = 'hidePlatesWhenFishing',
    hideLootToasts = 'hideLootToasts',
  });
end);
