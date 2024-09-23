local _, addon = ...;

if (_G.TradeSkillUI == nil) then return end

local Migration = addon.import('core/logic/Migration');

Migration.addMigration('3.1', function (variables)
  Migration.migrateOptionsToSubobject(variables.farmerOptions, 'Professions', {
    skills = 'displayProfessions',
    professions = 'displayProfessions',
  });
end);
