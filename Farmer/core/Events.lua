local addonName, addon = ...;

local events = {};
local eventFrame = CreateFrame('frame');

function addon:on (eventList, callback)
  assert(type(callback) == 'function', addonName .. ': callback is not a function');

  if (type(eventList) ~= 'table') then
    eventList = {eventList};
  end

  for x = 1, #eventList, 1 do
    local event = eventList[x];
    local list = events[event];

    if (list == nil) then
      events[event] = {callback};
      eventFrame:RegisterEvent(event);
    else
      list[#list + 1] = callback;
    end
  end
end

function addon:off (eventList, callback)
  assert(type(callback) == 'function', addonName .. ': callback is not a function');

  if (type(eventList) ~= 'table') then
    eventList = {eventList};
  end

  for x = 1, #eventList, 1 do
    local event = eventList[x];
    local list = events[event];
    local success = false;

    assert(list ~= nil, addonName .. ': no hook was registered for event ' .. event);

    for y = 1, #list, 1 do
      if (callback == list[y]) then
        success = true;
        table.remove(list, y);
        y = y - 1;
      end
    end

    assert(success == true, addonName .. ': no hook was registered for event ' .. event);

    if (#list == 0) then
      events[event] = nil;
      eventFrame:UnregisterEvent(event);
    end
  end
end

local function eventHandler (self, event, ...)
  local callbackList = events[event];

  for i = 1, #callbackList, 1 do
    callbackList[i](...);
  end
end

do
  local updateFrame = CreateFrame('Frame');
  local updateList;

  function executeUpdateCallbacks ()
    local list = updateList;

    updateFrame:SetScript('OnUpdate', nil);
    updateList = nil;

    for x = 1, #list, 1 do
      list[x]();
    end
  end

  function addon:executeOnNextFrame (callback)
    if (updateList == nil) then
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
function addon:funnel (eventList, ...)
  local minTime = 0.01;
  local arguments = {...};
  local flag = false;
  local timeSpan;
  local callback;
  local funnel;

  if (#arguments >= 2) then
    timeSpan = arguments[1];
    callback = arguments[2];
  else
    timeSpan = 0;
    callback = arguments[1];
  end

  funnel = function (...)
    local args = {...};

    if (flag == true) then
      return print('funneled', eventList);
    end

    flag = true;

    local handler = function ()
      flag = false;
      callback(unpack(args));
    end

    if (timeSpan < minTime) then
      addon:executeOnNextFrame(handler);
    else
      C_Timer.After(timeSpan, handler);
    end
  end

  addon:on(eventList, funnel);

  -- returning funnel for manual call
  return funnel;
end

eventFrame:SetScript('OnEvent', eventHandler);
