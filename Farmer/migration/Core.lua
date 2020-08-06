local _, addon = ...;

local Migrate = addon.Migration;

Migrate.addMigration('3.1', function (variables)
  Migrate.migrateOptionsToSubobject(variables.farmerOptions, 'Core', {
    anchor = 'anchor',
    displayTime = 'displayTime',
    fontSize = 'fontSize',
    iconScale = 'iconScale',
    outline = 'outline',
    hideAtMailbox = 'hideAtMailbox',
    hideInArena = 'hideInArena',
    hideOnExpeditions = 'hideOnExpeditions',
    itemNames = 'itemNames',
  });
end);
