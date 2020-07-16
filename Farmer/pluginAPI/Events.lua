local _, addon = ...;

local events = {};

addon.API.events = events;

function events.on(eventName, callback)
  addon.on(eventName, function (...)
    pcall(callback, ...);
  end);
end
