local addonName, addon = ...;

addon.L = setmetatable({}, {
  __index = function (_, key)
    addon.Debug.print('missing translation: ', key);
    return key;
  end,
});
