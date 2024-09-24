local _, addon = ...;

local CallbackHandler = addon.import('core/classes/CallbackHandler');
local Events = addon.import('core/logic/Events');

local module = addon.export('client/utils/Events', {});

local showCallbackHandler = CallbackHandler:new();
local hideCallbackHandler = CallbackHandler:new();

Events.on('PLAYER_INTERACTION_MANAGER_FRAME_SHOW', function (event, type, ...)
  showCallbackHandler:call(type, event, type, ...);
end);

Events.on('PLAYER_INTERACTION_MANAGER_FRAME_HIDE', function (event, type, ...)
  hideCallbackHandler:call(type, event, type, ...);
end);

function module.onInteractionFrameShow (type, callback)
  showCallbackHandler:add(type, callback);
end

function module.onInteractionFrameHide (type, callback)
  hideCallbackHandler:add(type, callback);
end
