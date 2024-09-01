local addonName, addon = ...;

local strsplit = _G.strsplit;

local TOC_VERSION = _G.C_AddOns.GetAddOnMetadata(addonName, 'version');

local Migration = addon:extend('Migration', {});
local callbackHandler = addon.import('Class/CallbackHandler'):new();

local function versionToNumber (version)
  local segmentCount = 3;

  if (type(version) == 'number') then
    assert(version >= 0 and version < 100 ^ segmentCount,
        'version is out of range: ' .. version);

    return version;
  end

  local split = {strsplit('.', version)};
  local result = 0;

  assert(#split <= segmentCount, 'version has too many segments: ' .. version);

  for x = 1, segmentCount, 1 do
    local subVersion = tonumber(split[x] or 0);

    result = result + 100 ^ (segmentCount - x) * subVersion;
  end

  return result;
end

local function getLastVersion (variables)
  local store = variables.farmerOptions;

  store = store and store.Migrate;
  store = store and store.lastVersion;

  if (store == nil) then
    return nil;
  end

  return versionToNumber(store);
end

local function storeCurrentVersion (variables)
  variables.farmerOptions = variables.farmerOptions or {};
  variables.farmerOptions.Migrate = variables.farmerOptions.Migrate or {};
  variables.farmerOptions.Migrate.lastVersion = versionToNumber(TOC_VERSION);
end

local function executeMigrationHandlers (variables)
  local lastVersion = getLastVersion(variables);

  if (lastVersion == nil) then
    return;
  end

  local versionList = callbackHandler:getSortedIdentifiers();

  for _, version in ipairs(versionList) do
    if (version >= lastVersion) then
      callbackHandler:call(version, variables, lastVersion);
    end
  end
end

function Migration.addMigration (version, handler)
  callbackHandler:addCallback(versionToNumber(version), handler);
end

function Migration.migrate (variables)
  executeMigrationHandlers(variables);
  storeCurrentVersion(variables);
  callbackHandler:clear();
  callbackHandler = nil;
end

function Migration.migrateOptionsToSubobject(options, subKey, mapping)
  if (options == nil) then return end

  local subObject = options[subKey] or {};

  options[subKey] = subObject;

  -- print('migrating', subKey);

  for oldKey, newKey in pairs(mapping) do
    local oldValue = options[oldKey];

    if (oldValue ~= nil) then
      options[oldKey] = nil;
      subObject[newKey] = oldValue;
      -- print('migrated', oldKey, 'to', subKey .. '/' .. newKey);
    end
  end
end
