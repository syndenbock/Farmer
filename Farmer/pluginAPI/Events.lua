local _, addon = ...;

local secureCall = addon.secureCall;

local events = {};

addon.API.events = events;

function events.on(eventName, callback)
  addon.on(eventName, function (...)
    secureCall(callback, ...);
  end);
end
