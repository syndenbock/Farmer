local addonName, addon = ...;

local Migration = addon.Migration;

local VERSION_TOC = _G.GetAddOnMetadata(addonName, 'version');

local function checkLegacyVersion (options)
  if (options and (options.version ~= nil)) then
    options.version = nil;
    return true;
  end

  return false;
end

Migration.addMigration ('3.1', function (variables, lastVersion)
  if (lastVersion == 0 and
      not checkLegacyVersion(variables.farmerOptions)) then
    return;
  end

  local text = {
      'New in ' .. addonName .. ' version ' .. VERSION_TOC .. ':',
      '- Farmer can now automatically sell gray items and repair your gear when you visit a vendor',
      '- The farm radar now has some options for toggling nodes and tooltips',
      '- Some options have been moved to better fitting categories - no options have been removed!',
      'Make sure to check out those new features in the options!',
  };

  for x = 1, #text, 1 do
    print(text[x]);
  end
end);

addon.slash('version', function ()
  print(addonName .. ' version ' .. VERSION_TOC);
end);
