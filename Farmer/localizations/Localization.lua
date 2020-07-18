local addonName, addon = ...;

addon.L = setmetatable({}, {
  __index = function (_, key)
    print(addonName, '- missing translation: ', key);
    return key;
  end,
});
