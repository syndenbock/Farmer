local _, addon = ...;

local tinsert = _G.tinsert;

local Set = addon.Factory.Set;

local variableStorage = {};
local awaiting = {};
local loadCallbacks = {};
local defaultValues = {};

local function isArray (table)
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
    if (type(value) == 'table') then
      if (type(target[key]) ~= 'table') then
        target[key] = {};
      end

      assignObject(target[key], value);
    else
      target[key] = source[key];
    end
  end
end

local function fillObject (target, source)
  for key, value in pairs(source) do
    local currentValue = target[key];

    if (currentValue == nil) then
      target[key] = value;
    elseif (type(currentValue) == 'table' and not isArray(currentValue)) then
      fillObject(currentValue, value);
    end
  end
end

local function readGlobalsIntoObject (object, globalNames)
  local loaded = {};

  for globalName in pairs(globalNames) do
    loaded[globalName] = _G[globalName];
  end

  assignObject(object, loaded);
end

local function readAddonVariables(addonName)
  local variableSet = awaiting[addonName];

  if (not variableSet) then
    return;
  end

  local defaults = defaultValues[addonName];
  local loaded = variableStorage[addonName];

  readGlobalsIntoObject(loaded, variableSet:getItems());

  defaultValues[addonName] = nil;
  awaiting[addonName] = nil;
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
  executeLoadCallbacks(addonName);
end);

addon.on('PLAYER_LOGOUT', globalizeSavedVariables);

local function SavedVariablesHandler (addonName, variables, defaults)
  local variableSet = awaiting[addonName] or Set:new(variables);
  local vars = variableStorage[addonName] or {};

  defaultValues[addonName] = defaultValues[addonName] or {};
  fillObject(vars, defaults or {});
  fillObject(defaultValues[addonName], defaults or {});

  awaiting[addonName] = variableSet;
  variableStorage[addonName] = vars;

  return {
    vars = vars,
    OnLoad = function (_, callback)
      addLoadListener(addonName, callback);
    end,
  };
end

addon.SavedVariablesHandler = SavedVariablesHandler;
