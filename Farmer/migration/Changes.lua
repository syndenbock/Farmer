local addonName, addon = ...;

local Migration = addon.Migration;

local VERSION_TOC = _G.C_AddOns.GetAddOnMetadata(addonName, 'version');

local function checkLegacyVersion (options)
  if (options and (options.version ~= nil)) then
    options.version = nil;
    return true;
  else
    return false;
  end
end

local function printVersionMessage (lines)
  print('New in ' .. addonName .. ' version ' .. VERSION_TOC .. ':');

  for _, line in ipairs(lines) do
    print(line);
  end
end

Migration.addMigration ('3.1', function (variables, lastVersion)
  if (not checkLegacyVersion(variables.farmerOptions) and lastVersion == 0) then
    return;
  end

  printVersionMessage({
    '- Farmer can now automatically sell gray items and repair your gear when you visit a vendor',
    '- The farm radar now has some options for toggling nodes and tooltips',
    '- The farm radar should be more compatible with other addons',
    '- Some options have been moved to better fitting categories - no options have been removed!',
    'Make sure to check out those new features in the options!',
  });
end);

Migration.addMigration('3.2.3', function (variables, lastVersion)
  if (not checkLegacyVersion(variables.farmerOptions) and lastVersion == 0) then
    return;
  end

  printVersionMessage({
    '- Farmer has new options for text alignment, growth and line spacing',
    '- Farmer can now detect and display vignettes that appear on the minimap',
    'Make sure to check out those new features in the options!',
  });
end);

Migration.addMigration('3.4.2', function ()
  printVersionMessage({
    '- Farmer can now display experience you gain.',
    'You can enable the option and set a minimum threshold in the options panel.',
  });
end);

addon.slash('version', function ()
  addon.printAddonMessage('Version is', VERSION_TOC);
end);
