local addonName, addon = ...;

local secureCall = addon.secureCall;

local eventFrame = _G.CreateFrame('frame');
local callbackHandler = addon.import('Class/CallbackHandler'):new();
local singleFireCallbacks = {};

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

local function callSingleFireCallbacks (event, ...)
  if (singleFireCallbacks[event] == nil) then return end

  for callback in pairs(singleFireCallbacks[event]) do
    secureCall(callback, event, ...);
  end

  singleFireCallbacks[event] = nil;
  removeCallback(event, callSingleFireCallbacks);
end

local function addSingleFireCallback (event, callback)
  if (singleFireCallbacks[event] == nil) then
    singleFireCallbacks[event] = {};
    addCallback(event, callSingleFireCallbacks);
  end

  singleFireCallbacks[event][callback] = true;
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
