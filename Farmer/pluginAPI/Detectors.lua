local addonName, addon = ...;

local unpack = _G.unpack;

local detectors = {};

addon.API.detectors = detectors;

local ALLOWED_HOOKS = {
  NEW_ITEM = true,
  CURRENCY_CHANGED = true,
  MONEY_CHANGED = true,
  PROFESSION_CHANGED = true,
  SKILL_CHANGED = true,
  REPUTATION_CHANGED = true,
};

function detectors:on(hook, callback)
  assert(ALLOWED_HOOKS[hook] ~= nil, addonName .. ': unknown detector: ' .. hook);

  addon:listen(hook, function (...)
    pcall(callback, ...);
  end);
end
