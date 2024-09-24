local _, addon = ...;

local Migration = addon.import('core/logic/Migration');

Migration.addMigration('3.1', function (variables)
  Migration.migrateOptionsToSubobject(variables.farmerOptions, 'Reputation', {
    reputation = 'displayReputation',
    reputationThreshold = 'reputationThreshold',
  });
end);
