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

Migrate.addMigration('3.2.3', function (variables)
  local options = variables.farmerOptions;

  options = options and options.Core;

  if (not options) then return end

  if (options.fontSize) then
    options.fontSize = addon.round(options.fontSize / _G.UIParent:GetScale());
  end

  if (options.anchor) then
    options.anchor = nil;
  end
end);
