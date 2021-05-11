local addonName, addon = ...;

local proxy = {};

setmetatable(addon, {
  __metatable = false,
  __index = proxy,
  __newindex = function (_, key, value)
    assert(proxy[key] == nil,
        addonName .. ': addon key already in use: ' .. key);

    proxy[key] = value;
  end,
});

function addon.share (name)
  local shared = proxy[name];

  if (shared == nil) then
    shared = {};
    proxy[name] = shared;
  end

  return shared;
end
