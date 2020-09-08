local _, addon = ...;

local Migration = addon.Migration;

Migration.addMigration('3.1', function (variables)
  Migration.migrateOptionsToSubobject(variables.farmerOptions, 'SellAndRepair', {
    autoRepair = 'autoRepair',
    autoRepairAllowGuild = 'autoRepairAllowGuild',
    autoSell = 'autoSell',
    autoSellSkipReadable = 'autoSellSkipReadable',
  });
end);
