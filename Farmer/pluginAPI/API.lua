local addonName, addon = ...;

local API = {};
local proxy = {};

addon.API = API;

function proxy:__index (key)
  return proxy[key];
end

function proxy:__newindex (key, value)
  assert(proxy[key] == nil, addonName .. ': addon key already in use: ' .. key);
  proxy[key] = value;
end

setmetatable(API, proxy);

_G.FARMER_API = API;
