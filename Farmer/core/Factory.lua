local addonName, addon = ...;

local Factory = {};

addon.Factory = Factory;

local function createMetaTable (baseMap, mode)
  local metaTable = {__mode = mode};

  if (baseMap == nil) then
    baseMap = {};
  end

  setmetatable(baseMap, metaTable);

  return baseMap;
end

function Factory.WeakKeyMap (baseMap)
  --[[ Mode 'k' makes the keys weak ]]
  return createMetaTable(baseMap, 'k');
end

function Factory.WeakValueMap (baseMap)
  --[[ Mode 'v' makes the values weak ]]
  return createMetaTable(baseMap, 'v');
end

function Factory.WeakMap (baseMap)
  --[[ Mode 'kv' makes keys and values weak ]]
  return createMetaTable(baseMap, 'kv');
end
