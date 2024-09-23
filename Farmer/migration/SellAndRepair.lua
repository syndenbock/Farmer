local _, addon = ...;

local Migration = addon.import('core/logic/Migration');

Migration.addMigration('3.1', function (variables)
  Migration.migrateOptionsToSubobject(variables.farmerOptions, 'SellAndRepair', {
    autoRepair = 'autoRepair',
    autoRepairAllowGuild = 'autoRepairAllowGuild',
    autoSell = 'autoSell',
    autoSellSkipReadable = 'autoSellSkipReadable',
  });
end);
