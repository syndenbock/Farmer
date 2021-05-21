local _, addon = ...;

if (_G.GetSkillLineInfo == nil) then return end

local Migration = addon.Migration;

Migration.addMigration('3.1', function (variables)
  Migration.migrateOptionsToSubobject(variables.farmerOptions, 'Skills', {
    skills = 'displaySkills',
  });
end);
