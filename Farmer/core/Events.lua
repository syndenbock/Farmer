local addonName, addon = ...;

local tinsert = _G.tinsert;
local C_Timer = _G.C_Timer;

local callbackHandler = addon.Class.CallbackHandler:new();

local eventFrame = _G.CreateFrame('frame');

eventFrame:SetScript('OnEvent', function (_, event, ...)
  callbackHandler:call(event, ...);
end);

local function hookEvent (eventName, callback)
  if (callbackHandler:addCallback(eventName, callback)) then
    eventFrame:RegisterEvent(eventName);
  end
end

local function hookMultipleEvents (eventList, callback)
  for x = 1, #eventList, 1 do
    hookEvent(eventList[x], callback);
  end
end

local function unhookEvent (eventName, callback)
  callbackHandler:removeCallback(eventName, callback);
end

function addon.on (eventList, callback)
  assert(type(callback) == 'function',
    addonName .. ': callback is not a function');

  if (type(eventList) == 'table') then
    hookMultipleEvents(eventList, callback);
  else
    hookEvent(eventList, callback);
  end
end

local function unhookMultipleEvents (eventList, callback)
  for x = 1, #eventList, 1 do
    unhookEvent(eventList[x], callback);
  end
end

function addon.off (eventList, callback)
  assert(type(callback) == 'function',
    addonName .. ': callback is not a function');

  if (type(eventList) == 'table') then
    unhookMultipleEvents(eventList, callback);
  else
    unhookEvent(eventList, callback);
  end
end

do
  local updateFrame = _G.CreateFrame('Frame');
  local updateList;

  local function executeUpdateCallbacks ()
    local list = updateList;

    -- updateList has to be swapped out before executing callbacks so if
    -- callbacks add new hooks they are not immediately executed
    updateFrame:SetScript('OnUpdate', nil);
    updateList = nil;

    for x = 1, #list, 1 do
      list[x]();
    end
  end

  function addon.executeOnNextFrame (callback)
    if (not updateList) then
      updateList = {callback};
      updateFrame:SetScript('OnUpdate', executeUpdateCallbacks);
    else
      tinsert(updateList, callback);
    end
  end
end

--[[
//##############################################################################
// event funneling
//##############################################################################
--]]
local function generateFunnel (timeSpan, callback)
  local minTime = 0.01;
  local flag = false;
  local handler = function ()
    flag = false;
    callback();
  end

  local funnel = function ()
    if (flag) then
      return;
    end

    flag = true;

    if (timeSpan < minTime) then
      addon.executeOnNextFrame(handler);
    else
      C_Timer.After(timeSpan, handler);
    end
  end

  return funnel;
end

local function registerFunnel (eventList, timeSpan, callback)
  local funnel = generateFunnel(timeSpan, callback);

  addon.on(eventList, funnel);

  return funnel;
end

function addon.funnel (eventList, ...)
  local arguments = {...};
  local callback;
  local timeSpan;

  if (#arguments >= 2) then
    timeSpan = arguments[1];
    callback = arguments[2];
  else
    timeSpan = 0;
    callback = arguments[1];
  end

  return registerFunnel(eventList, timeSpan, callback);
end
