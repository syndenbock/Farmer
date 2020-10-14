local addonName, addon = ...;

local strsplit = _G.strsplit;

local CURRENT_VERSION = '3.4';
local TOC_VERSION = _G.GetAddOnMetadata(addonName, 'version');

local Migration = {};
local callbackHandler = addon.Class.CallbackHandler:new();

addon.Migration = Migration;

local function versionToNumber (version)
  if (not version) then return 0 end

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

  return versionToNumber(store);
end

local function storeCurrentVersion (variables)
  variables.farmerOptions = variables.farmerOptions or {};
  variables.farmerOptions.Migrate = variables.farmerOptions.Migrate or {};
  variables.farmerOptions.Migrate.lastVersion = versionToNumber(CURRENT_VERSION);
end

local function executeMigrationHandlers (variables)
  local lastVersion = getLastVersion(variables);
  local versionList = callbackHandler:getSortedIdentifiers();

  for x = 1, #versionList, 1 do
    local version = versionList[x];

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

do
  TOC_VERSION = versionToNumber(TOC_VERSION);
  CURRENT_VERSION = versionToNumber(CURRENT_VERSION);

  if (TOC_VERSION > CURRENT_VERSION) then
    print(addon.stringJoin({
      addonName .. ': you seem to have rolled back to an older version while the client was running.',
      'Please restart the client to prevent errors.'
    }, ' '));
  elseif (CURRENT_VERSION > TOC_VERSION) then
    print(addon.stringJoin({
      addonName .. ': you seem to have installed a new version while the client was running.',
      'Please restart the client to prevent errors.'
    }, ' '));
  end
end
