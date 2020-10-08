local thisAddonName, addon = ...;

local tinsert = _G.tinsert;

local Set = addon.Class.Set;

local variableStorage = {};
local awaiting = {};
local loadCallbacks = {};

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
end

local function readGlobalsIntoObject (object, globalNames)
  local loaded = {};

  for x = 1, #globalNames, 1 do
    local globalName = globalNames[x];

    loaded[globalName] = _G[globalName];
  end

  assignObject(object, loaded);
end

local function readAddonVariables(addonName)
  local variableSet = awaiting[addonName];

  if (not variableSet) then
    return;
  end

  readGlobalsIntoObject(variableStorage[addonName], variableSet:getItems());

  awaiting[addonName] = nil;
end

local function migrateAddonVariables (addonName)
  if (addonName ~= thisAddonName) then return end

  addon.Migration.migrate(variableStorage[addonName] or {});
end

local function executeCallbackList (callbackList, ...)
  for x = 1, #callbackList, 1 do
    callbackList[x](...);
  end
end

local function executeLoadCallbacks (addonName)
  local callbackList = loadCallbacks[addonName];

  if (not callbackList) then return end

  executeCallbackList(callbackList, variableStorage[addonName]);
  loadCallbacks[addonName] = nil;
end

local function addLoadListener (addonName, callback)
  assert(type(callback) == 'function', 'callback is not a function');

  local callbackList = loadCallbacks[addonName] or {};

  tinsert(callbackList, callback)
  loadCallbacks[addonName] = callbackList;
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

addon.on('ADDON_LOADED', function (addonName)
  readAddonVariables(addonName);
  migrateAddonVariables(addonName);
  executeLoadCallbacks(addonName);
end);

addon.on('PLAYER_LOGOUT', globalizeSavedVariables);

local function SavedVariablesHandler (addonName, variables, defaults)
  local variableSet = awaiting[addonName];
  local vars = variableStorage[addonName];

  if (not variableSet) then
    variableSet = Set:new(variables);
    awaiting[addonName] = variableSet;
  else
    variableSet:add(variables);
  end

  if (not vars) then
    vars = {};
    variableStorage[addonName] = vars;
  end

  fillObject(vars, defaults or {});

  return {
    vars = vars,
    OnLoad = function (_, callback)
      addLoadListener(addonName, callback);
    end,
  };
end

addon.SavedVariablesHandler = SavedVariablesHandler;
