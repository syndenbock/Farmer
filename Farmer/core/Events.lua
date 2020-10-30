local addonName, addon = ...;

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
  for _, event in ipairs(eventList) do
    hookEvent(event, callback);
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
  for _, event in ipairs(eventList) do
    unhookEvent(event, callback);
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

--[[
//##############################################################################
// event funneling
//##############################################################################
--]]
local function generateFunnel (timeSpan, callback)
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
    C_Timer.After(timeSpan, handler);
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
