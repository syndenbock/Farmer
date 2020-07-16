local _, addon = ...;

addon.L = setmetatable({}, {
  __index = function (_, key)
    return key;
  end,
});
