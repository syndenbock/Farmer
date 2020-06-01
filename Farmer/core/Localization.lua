local addonName, addon = ...;

local L = setmetatable({}, {
  __index = function (table, key)
      return key;
  end,
});

addon.L = L;
