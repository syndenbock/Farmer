local addonName, addon = ...;

local Debug = {};
local enabled = false;

addon.Debug = Debug;

function Debug.setEnabled (value)
  enabled = value;
end

function Debug.print(...)
  if (not enabled) then return end

  print(addonName .. '-debug:', ...);
end

function Debug.call (func, ...)
  if (not enabled) then return end

  pcall(func, ...);
end
