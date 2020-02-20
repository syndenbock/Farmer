local addonName, addon = ...;

local callbacks = {};

function addon:listen (message, callback)
  callbacks[message] = callbacks[message] or {};

  table.insert(callbacks[message], callback);
end

function addon:yell (message, ...)
  local callbackList = callbacks[message];

  if (callbackList == nil) then return end

  for x = 1, #callbackList, 1 do
    callbackList[1](...);
  end
end
