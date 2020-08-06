local addonName, addon = ...;

local strsplit = _G.strsplit;

local CURRENT_VERSION = _G.GetAddOnMetadata(addonName, 'version');

local callbackHandler = addon.Class.CallbackHandler:new();
local lastVersion;

local Migration = {};

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

local function readLastVersion (variables)
  if (lastVersion ~= nil) then return end

  local store = variables.farmerOptions;

  store = store and store.Migrate;
  store = store and store.lastVersion;
  lastVersion = versionToNumber(store);
end

local function createVersionCheckCallback (version, callback)
  return function (lastVersion, variables)
    if (lastVersion > version) then return end

    callback(variables, lastVersion);
  end
end

local function storeCurrentVersion (variables)
  variables.farmerOptions = variables.farmerOptions or {};
  variables.farmerOptions.Migrate = variables.farmerOptions.Migrate or {};
  variables.farmerOptions.Migrate.lastVersion =
    versionToNumber(CURRENT_VERSION);

    readLastVersion();
end

function Migration.addMigration (version, handler)
  version = versionToNumber(version);
  callbackHandler:addCallback(version,
      createVersionCheckCallback(version, handler));
end

function Migration.migrate (variables)
  callbackHandler:sortIdentifiers();
  readLastVersion(variables);
  callbackHandler:callAll(lastVersion, variables);
  callbackHandler:clear();
  callbackHandler = nil;

  storeCurrentVersion(variables);
end

function Migration.migrateOptionsToSubobject(options, subKey, mapping)
  if (options == nil) then return end

  local subObject = options[subKey] or {};

  options[subKey] = subObject;

  for oldKey, newKey in pairs(mapping) do
    local oldValue = options[oldKey];

    if (oldValue ~= nil) then
      options[oldKey] = nil;
      subObject[newKey] = oldValue;
    end
  end
end
