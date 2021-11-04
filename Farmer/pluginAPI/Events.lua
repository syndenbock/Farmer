local _, addon = ...;

local secureCall = addon.secureCall;

local events = {};
local callbackMap = {};

addon.API.events = events;

local function handleEvent (event, ...)
  for callback in pairs(callbackMap[event]) do
    secureCall(callback, event, ...);
  end
end

local function addEvent (event, callback)
  if (callbackMap[event] == nil) then
    addon.on(event, handleEvent);
    callbackMap[event] = {[callback] = true};
  else
    callbackMap[event][callback] = true;
  end
end

function events.on(eventList, callback)
  if (type(eventList) == "table") then
    for _, event in ipairs(eventList) do
      addEvent(event, callback);
    end
  else
    addEvent(eventList, callback);
  end
end
