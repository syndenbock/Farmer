local _, addon = ...;

local tinsert = _G.tinsert;

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

local function fillDefaults (settings, defaults)
  for key, value in pairs(defaults) do
    local currentValue = settings[key];

    if (currentValue == nil) then
      settings[key] = value;
    elseif (type(currentValue) == 'table' and not isArray(currentValue)) then
      fillDefaults(currentValue, value);
    end
  end
end

local function readAddonVariables(addonName)
  local vars = awaiting[addonName];

  if (not vars) then
    return;
  end

  local defaults = defaultValues[addonName];
  local loaded = variableStorage[addonName];

  for variable in pairs(vars) do
    loaded[variable] = _G[variable];
  end

  fillDefaults(loaded, defaults);

  defaultValues[addonName] = nil;
  awaiting[addonName] = nil;
end

local function executeLoadCallbacks (addonName)
  local callbackList = loadCallbacks[addonName];

  if (not callbackList) then return end

  local vars = variableStorage[addonName];

  for x = 1, #callbackList, 1 do
    callbackList[x](vars);
  end

  loadCallbacks[addonName] = nil;
end

local function addLoadListener (addonName, callback)
  local callbackList = loadCallbacks[addonName] or {};

  tinsert(callbackList, callback)
  loadCallbacks[addonName] = callbackList;
end

addon:on('ADDON_LOADED', function (addonName)
  readAddonVariables(addonName);
  executeLoadCallbacks(addonName);
end);

addon:on('PLAYER_LOGOUT', function ()
  for _, vars in pairs(variableStorage) do
    for variableName, value in pairs(vars) do
      _G[variableName] = value;
    end
  end
end);

local function SavedVariablesHandler (addonName, variables, defaults)
  local variableMap = awaiting[addonName] or {};
  local vars = variableStorage[addonName] or {};

  defaults = defaults or {};

  if (type(variables) ~= 'table') then
    variables = {variables};
  end

  for x = 1, #variables, 1 do
    variableMap[variables[x]] = true;
  end

  defaultValues[addonName] = defaultValues[addonName] or {};
  fillDefaults(vars, defaults)
  fillDefaults(defaultValues[addonName], defaults);

  awaiting[addonName] = variableMap;
  variableStorage[addonName] = vars;

  return {
    vars = vars,
    OnLoad = function (_, callback)
      addLoadListener(addonName, callback);
    end,
  };
end

addon.SavedVariablesHandler = SavedVariablesHandler;
