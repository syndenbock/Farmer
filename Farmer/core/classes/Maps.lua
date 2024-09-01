local _, addon = ...;

local function createMetaTable (baseMap, mode)
  return setmetatable(baseMap or {}, {__mode = mode});
end

addon.export('Factory/WeakKeyMap', function (baseMap)
  --[[ Mode 'k' makes the keys weak ]]
  return createMetaTable(baseMap, 'k');
end);

addon.export('Factory/WeakValueMap', function (baseMap)
  --[[ Mode 'v' makes the values weak ]]
  return createMetaTable(baseMap, 'v');
end);

addon.export('Factory/WeakMap', function (baseMap)
  --[[ Mode 'kv' makes keys and values weak ]]
  return createMetaTable(baseMap, 'kv');
end);

addon.export('Factory/ImmutableMap', function (baseMap)
  return setmetatable({}, {
    __index = baseMap,
    __newindex = function ()
      error('tried to modify immutable table');
    end,
    __metatable = false,
  });
end);
