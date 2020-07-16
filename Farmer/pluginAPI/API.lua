local addonName, addon = ...;

local API = {};

addon.API = setmetatable({}, {
  __metatable = false,
  __index = API,
  __newindex = function (_, key, value)
    assert(API[key] == nil, addonName .. ': API key already in use: ' .. key);
    API[key] = value;
  end
});

_G.FARMER_API = API;
