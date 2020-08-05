local _, addon = ...;

if (addon.isClassic()) then return end

local Migration = addon.Migration;

Migration.addMigration('3.1', function (variables)
  Migration.migrateOptionsToSubobject(variables.farmerOptions, 'Reputation', {
    reputation = 'displayReputation',
    reputationThreshold = 'reputationThreshold',
  });
end);
