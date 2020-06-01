local _, addon = ...;

local tinsert = _G.tinsert;
local callbacks = {};

function addon:listen (message, callback)
  callbacks[message] = callbacks[message] or {};

  tinsert(callbacks[message], callback);
end

function addon:yell (message, ...)
  local callbackList = callbacks[message];

  if (callbackList == nil) then return end

  for x = 1, #callbackList, 1 do
    callbackList[x](...);
  end
end
