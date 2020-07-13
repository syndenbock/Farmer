local _, addon = ...;

local tinsert = _G.tinsert;
local callbacks = {};

function addon:listen (message, callback)
  callbacks[message] = callbacks[message] or {};

  tinsert(callbacks[message], callback);
end

local function executeCallbackList (callbackList, ...)
  for x = 1, #callbackList, 1 do
    callbackList[x](...);
  end
end

function addon:yell (message, ...)
  local callbackList = callbacks[message];

  if (not callbackList) then return end

  executeCallbackList(callbackList, ...);
end
