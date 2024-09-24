local _, addon = ...;

local CallbackHandler = addon.import('core/classes/CallbackHandler');

local module = addon.export('core/logic/Yell', {});

local callbackHandler = CallbackHandler:new();

function module.listen (message, callback)
  callbackHandler:addCallback(message, callback);
end

function module.unlisten (message, callback)
  callbackHandler:removeCallback(message, callback);
end

function module.yell (message, ...)
  callbackHandler:call(message, ...);
end
