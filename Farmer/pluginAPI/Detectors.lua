local addonName, addon = ...;

local secureCall = addon.secureCall;

local Yell = addon.import('core/logic/Yell');

local detectors = addon.export('API/detectors', {});

local ALLOWED_HOOKS = {
  ITEM_CHANGED = true,
  CURRENCY_CHANGED = true,
  MONEY_CHANGED = true,
  PROFESSION_CHANGED = true,
  SKILL_CHANGED = true,
  REPUTATION_CHANGED = true,
};

function detectors.on(hook, callback)
  assert(ALLOWED_HOOKS[hook] ~= nil, addonName .. ': unknown detector: ' .. hook);

  Yell.listen(hook, function (...)
    secureCall(callback, ...);
  end);
end
