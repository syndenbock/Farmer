local _, addon = ...;

local Factory = addon.share('Factory');

local function createMetaTable (baseMap, mode)
  local metaTable = {__mode = mode};

  baseMap = baseMap or {};

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

function Factory.ImmutableMap (baseMap)
  return setmetatable({}, {
    __index = baseMap,
    __newindex = function ()
      error('tried to modify immutable table');
    end,
    __metatable = false,
  });
end
