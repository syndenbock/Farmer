local addonName, addon = ...;

local CallAfter = _G.C_Timer.After;

local secureCall = addon.secureCall;

local eventFrame = _G.CreateFrame('frame');
local callbackHandler = addon.import('Class/CallbackHandler'):new();

eventFrame:SetScript('OnEvent', function (_, event, ...)
  callbackHandler:call(event, event, ...);
end);

local function addCallback (event, callback)
  if (callbackHandler:addCallback(event, callback)) then
    eventFrame:RegisterEvent(event);
  end
end

local function removeCallback (event, callback)
  if (callbackHandler:removeCallback(event, callback)) then
    eventFrame:UnregisterEvent(event);
  end
end

local function addSingleFireCallback (event, callback)
  local function wrapper (...)
    removeCallback(event, wrapper);
    secureCall(callback, ...);
  end

  addCallback(event, wrapper);
end

local function createFunnelCallback (callback)
  local triggered = false;

  local function wrapper ()
    triggered = false;
    callback();
  end

  return function ()
    if (not triggered) then
      triggered = true;
      CallAfter(0, wrapper);
    end
  end
end

local function callForEvents (events, callback, method)
  assert(type(callback) == 'function',
      addonName .. ': callback is not a function');

  if (type(events) == 'table') then
    for _, event in ipairs(events) do
      method(event, callback);
    end
  else
    method(events, callback);
  end
end

--##############################################################################
-- public methods
--##############################################################################

function addon.on (events, callback)
  callForEvents(events, callback, addCallback);
end

function addon.off (events, callback)
  callForEvents(events, callback, removeCallback);
end

function addon.onOnce (events, callback)
  callForEvents(events, callback, addSingleFireCallback);
end

function addon.funnel (eventList, callback)
  local funnelCallback = createFunnelCallback(callback);
  addon.on(eventList, funnelCallback);
  return funnelCallback;
end
