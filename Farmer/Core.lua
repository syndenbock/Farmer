local addonName, addon = ...;

local L = addon.L;

addon.vars = {};

--[[
///#############################################################################
/// proxy
///#############################################################################
--]]
do
  local proxy = {};

  function proxy:__index (key)
    return proxy[key];
  end

  function proxy:__newindex (key, value)
    assert(proxy[key] == nil, addonName .. ': addon key already in use: ' .. key);
    proxy[key] = value;
  end

  function proxy:__index (key)
    assert(proxy[key] ~= nil, addonName .. ': addon key does not exist: ' .. key);
    return proxy[key];
  end

  setmetatable(addon, proxy)
end
