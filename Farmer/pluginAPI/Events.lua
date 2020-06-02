local _, addon = ...;

local unpack = _G.unpack;

local events = {};

addon.API.events = events;

function events:on(eventName, callback)
  addon:on(eventName, function (...)
    pcall(callback, ...);
  end);
end
