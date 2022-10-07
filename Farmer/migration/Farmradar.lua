local _, addon = ...;

addon.Migration.addMigration('3.12.5', function (variables)
  local options = variables.farmerOptions;

  options = options and options.FarmRadar;

  if (options) then
    options.showGatherMateNodes = nil;
    options.showHandyNotesPins = nil;
  end
end);
