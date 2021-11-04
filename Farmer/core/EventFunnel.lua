local _, addon = ...;

local CallAfter = _G.C_Timer.After;
local wipe = _G.wipe;

local callbackMap = {};
local triggeredCallbacks = {};
local anyCallbacksTriggered = false;

local function callTriggeredCallbacks ()
  for callback in pairs(triggeredCallbacks) do
    callback();
  end

  anyCallbacksTriggered = false;
  wipe(triggeredCallbacks);
end

local function handleFunnel (event)
  for callback in pairs(callbackMap[event]) do
    triggeredCallbacks[callback] = true;
  end

  if (anyCallbacksTriggered == false) then
    CallAfter(0, callTriggeredCallbacks);
    anyCallbacksTriggered = true;
  end
end

local function addFunnel (event, callback)
  if (callbackMap[event] == nil) then
    callbackMap[event] = {[callback] = true};
    addon.on(event, handleFunnel);
  else
    callbackMap[event][callback] = true;
  end
end

--##############################################################################
-- public methods
--##############################################################################

function addon.funnel (eventList, callback)
  if (type(eventList) == 'table') then
    for _, event in ipairs(eventList) do
      addFunnel(event, callback);
    end
  else
    addFunnel(eventList, callback);
  end
end
