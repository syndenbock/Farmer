local _, addon = ...;

local CallbackHandler = addon.import('Class/CallbackHandler');

local module = addon.export('Utils/Events', {});

local showCallbackHandler = CallbackHandler:new();
local hideCallbackHandler = CallbackHandler:new();

addon.on('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', function (event, type, ...)
  showCallbackHandler:call(type, event, type, ...);
end);

addon.on('PLAYER_INTERACTION_MANAGER_FRAME_HIDE', function (event, type, ...)
  hideCallbackHandler:call(type, event, type, ...);
end);

function module.onInteractionFrameShow (type, callback)
  showCallbackHandler:add(type, callback);
end

function module.onInteractionFrameHide (type, callback)
  hideCallbackHandler:add(type, callback);
end
