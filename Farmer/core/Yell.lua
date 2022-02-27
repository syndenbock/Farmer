local _, addon = ...;

local callbackHandler = addon.Class.CallbackHandler:new();

addon.export('listen', function (message, callback)
  callbackHandler:addCallback(message, callback);
end);

addon.export('unlisten', function (message, callback)
  callbackHandler:removeCallback(message, callback);
end);

addon.export('yell', function (message, ...)
  callbackHandler:call(message, ...);
end);
