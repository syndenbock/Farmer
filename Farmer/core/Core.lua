local addonName, addon = ...;

local proxy = {};

function proxy:__newindex (key, value)
  assert(proxy[key] == nil, addonName .. ': addon key already in use: ' .. key);
  proxy[key] = value;
end

function proxy:__index (key)
  assert(proxy[key] ~= nil, addonName .. ': addon key does not exist: ' .. key);
  return proxy[key];
end

function proxy:share (name)
  local shared = proxy[name];

  if (shared == nil) then
    shared = {};
    proxy[name] = shared;
  end

  return shared;
end

setmetatable(addon, proxy);
