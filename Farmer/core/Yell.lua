local _, addon = ...;

local callbackHandler = addon.Factory.CallbackHandler:create();

function addon.listen (message, callback)
  callbackHandler:addCallback(message, callback);
end

function addon.unlisten (message, callback)
  callbackHandler:removeCallback(message, callback);
end

function addon.yell (message, ...)
  callbackHandler:call(message, ...);
end
