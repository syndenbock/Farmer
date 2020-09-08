local _, addon = ...;

if (not addon.isClassic()) then return end

local Migration = addon.Migration;

Migration.addMigration('3.1', function (variables)
  Migration.migrateOptionsToSubobject(variables.farmerOptions, 'Skills', {
    skills = 'displaySkills',
  });
end);
