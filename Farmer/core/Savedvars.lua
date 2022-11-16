local thisAddonName, addon = ...;

local tinsert = _G.tinsert;

local Set = addon.import('Class/Set');

local variableStorage = {};
local addonData = {};

local function isArray (table)
  if (next(table) == nil) then
    return false;
  end

  local x = 1;

  for _ in pairs(table) do
    if (table[x] == nil) then
      return false;
    end

    x = x + 1;
  end

  return true;
end

local function assignObject (target, source)
  for key, value in pairs(source) do
    if (type(value) == 'table' and not isArray(value)) then
      if (type(target[key]) ~= 'table') then
        target[key] = {};
      end

      assignObject(target[key], value);
    else
      target[key] = value;
    end
  end
end

local function fillObject (target, source)
  for key, value in pairs(source) do
    local currentValue = target[key];

    if (currentValue == nil) then
      if (type(value) == 'table') then
        target[key] = fillObject({}, value);
      else
        target[key] = value;
      end
    elseif (type(currentValue) == 'table' and not isArray(currentValue)) then
      fillObject(currentValue, value);
    end
  end

  return target;
end

local function readGlobalsIntoObject (object, variableSet)
  local loaded = {};

  variableSet:forEach(function (globalName)
    loaded[globalName] = _G[globalName];
  end);

  assignObject(object, loaded);
end

local function readAddonVariables (addonName)
  readGlobalsIntoObject(addonData[addonName].values,
      addonData[addonName].variables);
end

local function storeAddonVariables(addonName)
  variableStorage[addonName] = addonData[addonName].values;
end

local function migrateAddonVariables (addonName)
  if (addonName ~= thisAddonName) then return end

  if (addon.Migration) then
    addon.Migration.migrate(addonData[addonName].values or {});
  end
end

local function executeCallbackList (callbackList, ...)
  for _, callback in ipairs(callbackList) do
    callback(...);
  end
end

local function executeLoadCallbacks (addonName)
  if (addonData[addonName].callbacks) then
    executeCallbackList(addonData[addonName].callbacks,
      addonData[addonName].values);
  end
end

local function addLoadListener (addonName, callback)
  assert(type(callback) == 'function', 'callback is not a function');

  if (not addonData[addonName].callbacks) then
    addonData[addonName].callbacks = {};
  end

  tinsert(addonData[addonName].callbacks, callback);
end

local function handleAddonLoad (_, addonName)
  if (addonData[addonName] == nil) then
    return;
  end

  readAddonVariables(addonName);
  migrateAddonVariables(addonName);
  storeAddonVariables(addonName);
  executeLoadCallbacks(addonName);
  addonData[addonName] = nil;
end

local function globalizeVariables (variables)
  for variableName, value in pairs(variables) do
    _G[variableName] = value;
  end
end

local function globalizeSavedVariables ()
  for _, variables in pairs(variableStorage) do
    globalizeVariables(variables);
  end
end

addon.on('ADDON_LOADED', handleAddonLoad);
addon.on('PLAYER_LOGOUT', globalizeSavedVariables);

addon.SavedVariablesHandler = function (addonName, variables, defaults)
  local data = addonData[addonName];

  if (data == nil) then
    data = {
      variables = Set:new(),
      values = {},
    };
    data.interface = {
      vars = data.values,
      OnLoad = function (_, callback)
        addLoadListener(addonName, callback);
      end
    }
    addonData[addonName] = data;
  end

  data.variables:add(variables);

  if (defaults) then
    fillObject(data.values, defaults);
  end

  return data.interface;
end
