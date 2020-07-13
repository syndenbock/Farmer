local _, addon = ...;

local L = setmetatable({}, {
  __index = function (_, key)
    return key;
  end,
});

addon.L = L;
