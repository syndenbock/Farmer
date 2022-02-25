local _, addon = ...;

local CallAfter = _G.C_Timer.After;
local wipe = _G.wipe;

local callbackHandler = addon.Class.CallbackHandler:new();
local triggeredEvents = {};
local anyEventsTriggered = false;

local function callTriggeredEvents ()
  for event in pairs(triggeredEvents) do
    callbackHandler:call(event);
  end

  anyEventsTriggered = false;
  wipe(triggeredEvents);
end

local function handleFunnel (event)
  triggeredEvents[event] = true;

  if (not anyEventsTriggered) then
    CallAfter(0, callTriggeredEvents);
    anyEventsTriggered = true;
  end
end

local function addFunnel (event, callback)
  if (callbackHandler:addCallback(event, callback)) then
    addon.on(event, handleFunnel);
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
