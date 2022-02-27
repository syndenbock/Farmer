local addonName, addon = ...;

local strsplit = _G.strsplit;

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

function addon.share (path)
  local current = addon;

  path = {strsplit('/', path)};

  for _, name in pairs(path) do
    if (current[name] == nil) then
      current[name] = {};
    end

    current = current[name];
  end

  return current;
end
