local thisAddonName, addon = ...;

local tinsert = _G.tinsert;

local Set = addon.Class.Set;

local variableStorage = {};
local addonData = nil;

local function isArray (table)
  local x = 1;

  if (next(table) == nil) then
    return false;
  end

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
        local fill = {};

        fillObject(fill, value);
        target[key] = fill;
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
  local callbackList = addonData[addonName].callbacks;

  if (not callbackList) then return end

  executeCallbackList(callbackList, addonData[addonName].values);
end

local function addLoadListener (addonName, callback)
  assert(type(callback) == 'function', 'callback is not a function');

  local callbackList = addonData[addonName].callbacks;

  if (callbackList == nil) then
    addonData[addonName].callbacks = {callback};
  else
    tinsert(callbackList, callback)
  end
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

local function handleAddonLoad (_, addonName)
  if (addonData[addonName] == nil) then
    return;
  end

  readAddonVariables(addonName);
  storeAddonVariables(addonName);
  migrateAddonVariables(addonName);
  executeLoadCallbacks(addonName);
  addonData[addonName] = nil;

  if (next(addonData) == nil) then
    addonData = nil;
    addon.off('ADDON_LOADED', handleAddonLoad);
  end
end

addon.on('PLAYER_LOGOUT', globalizeSavedVariables);

local function SavedVariablesHandler (addonName, variables, defaults)
  if (addonData == nil) then
    addonData = {};
    addon.on('ADDON_LOADED', handleAddonLoad);
  end

  local data = addonData[addonName];

  if (data == nil) then
    data = {
      variables = Set:new(variables),
      values = fillObject({}, defaults or {}),
    };
    addonData[addonName] = data;
  else
    data.variables:add(variables);
    fillObject(data.values, defaults or {});
  end

  return {
    vars = data.values,
    OnLoad = function (_, callback)
      addLoadListener(addonName, callback);
    end,
  };
end

addon.SavedVariablesHandler = SavedVariablesHandler;
