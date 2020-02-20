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

local function eventHandler (self, event, ...)
  for i = 1, #events[event] do
    events[event][i](...);
  end
end

eventFrame:SetScript('OnEvent', eventHandler);
