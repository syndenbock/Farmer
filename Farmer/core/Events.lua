local addonName, addon = ...;

local events = {};
local eventFrame = CreateFrame('frame');

function addon:on (eventList, callback)
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
        list[y] = nil;
        y = y - 1;
      end
    end

    assert(success == true, addonName .. ': no hook was registered for event ' .. event);
  end
end

local function eventHandler (self, event, ...)
  for i = 1, #events[event] do
    events[event][i](...);
  end
end

--[[
//##############################################################################
// event funneling
//##############################################################################
--]]
function addon:funnel (eventList, ...)
  local arguments = {...};
  local flag = false;
  local timeSpan;
  local callback;

  if (#arguments >= 2) then
    timeSpan = arguments[1];
    callback = arguments[2];
  else
    timeSpan = 0;
    callback = arguments[1];
  end

  local funnel = function (...)
    local args = {...};

    if (flag == false) then
      flag = true;

      C_Timer.After(timeSpan, function ()
        flag = false;
        callback(unpack(args));
      end);
    end
  end

  addon:on(eventList, funnel);

  -- returning funnel for manual call
  return funnel;
end

eventFrame:SetScript('OnEvent', eventHandler);
