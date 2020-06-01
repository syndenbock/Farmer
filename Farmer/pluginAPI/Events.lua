local _, addon = ...;

local unpack = _G.unpack;

local events = {};

addon.API.events = events;

function events:on(eventName, callback)
  addon:on(eventName, function (...)
    local params = {...};

    pcall(function ()
      callback(unpack(params));
    end);
  end);
end
