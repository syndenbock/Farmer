local _, addon = ...;

if (_G.GetProfessionInfo == nil) then return end

local Migration = addon.Migration;

Migration.addMigration('3.1', function (variables)
  Migration.migrateOptionsToSubobject(variables.farmerOptions, 'Professions', {
    skills = 'displayProfessions',
    professions = 'displayProfessions',
  });
end);
