local addonName, farmerVars = ...;

local L = setmetatable({}, {
  __index = function (table, key)
      return key;
  end,
});

farmerVars.L = L;
