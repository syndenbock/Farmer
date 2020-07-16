local addonName, addon = ...;

setmetatable(addon, {
  __metatable = false,
  __index = function (_, key)
    print(addonName .. ': addon key does not exist: ' .. key);
  end,
  __newindex = function (_, key, value)
    assert(addon[key] == nil,
        addonName .. ': addon key already in use: ' .. key);

    rawset(addon, key, value);
  end,
});

function addon:share (name)
  local shared = rawget(addon, name);

  if (shared == nil) then
    shared = {};
    rawset(addon, name, shared);
  end

  return shared;
end
