local addonName, addon = ...;

local C_Timer = _G.C_Timer;
local tinsert = _G.tinsert;

local eventFrame = _G.CreateFrame('frame');
local callbackHandler = addon.Class.CallbackHandler:new();

eventFrame:SetScript('OnEvent', function (_, event, ...)
  callbackHandler:call(event, ...);
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
    callback(...);
    removeCallback(event, wrapper);
  end

  addCallback(event, wrapper);
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

function addon.onOnce (events, callback)
  callForEvents(events, callback, addSingleFireCallback);
end

function addon.off (events, callback)
  callForEvents(events, callback, removeCallback);
end

--[[
//##############################################################################
// event funneling
//##############################################################################
--]]

local function generateFunnel (timeSpan, callback)
  local paramCollection;
  local handler = function ()
    callback(paramCollection);
    paramCollection = nil;
  end

  local funnel = function (...)
    if (paramCollection == nil) then
      paramCollection = {};
      C_Timer.After(timeSpan, handler);
    end

    tinsert(paramCollection, {...});
  end

  return funnel;
end

local function registerFunnel (eventList, timeSpan, callback)
  local funnel = generateFunnel(timeSpan, callback);

  addon.on(eventList, funnel);

  return funnel;
end

function addon.funnel (eventList, ...)
  local arguments = {...};
  local callback;
  local timeSpan;

  if (#arguments >= 2) then
    timeSpan = arguments[1];
    callback = arguments[2];
  else
    timeSpan = 0;
    callback = arguments[1];
  end

  return registerFunnel(eventList, timeSpan, callback);
end
