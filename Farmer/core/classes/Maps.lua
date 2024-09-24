local _, addon = ...;

local module = addon.export('core/classes/Maps', {});

local function createMetaTable (baseMap, mode)
  return setmetatable(baseMap or {}, {__mode = mode});
end

function module.WeakKeyMap (baseMap)
  --[[ Mode 'k' makes the keys weak ]]
  return createMetaTable(baseMap, 'k');
end

function module.WeakValueMap (baseMap)
  --[[ Mode 'v' makes the values weak ]]
  return createMetaTable(baseMap, 'v');
end

function module.WeakMap (baseMap)
  --[[ Mode 'kv' makes keys and values weak ]]
  return createMetaTable(baseMap, 'kv');
end

function module.ImmutableMap (baseMap)
  return setmetatable({}, {
    __index = baseMap,
    __newindex = function ()
      error('tried to modify immutable table');
    end,
    __metatable = false,
  });
end
