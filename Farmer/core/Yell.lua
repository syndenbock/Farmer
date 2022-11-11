local _, addon = ...;

local callbackHandler = addon.import('Class/CallbackHandler'):new();

function addon.listen (message, callback)
  callbackHandler:addCallback(message, callback);
end

function addon.unlisten (message, callback)
  callbackHandler:removeCallback(message, callback);
end

function addon.yell (message, ...)
  callbackHandler:call(message, ...);
end
