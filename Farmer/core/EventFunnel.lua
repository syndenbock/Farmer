local _, addon = ...;

local CallAfter = _G.C_Timer.After;

local function createFunnelCallback (callback)
  local triggered = false;

  local function wrapper ()
    triggered = false;
    callback();
  end

  return function ()
    if (not triggered) then
      triggered = true;
      CallAfter(0, wrapper);
    end
  end
end

--##############################################################################
-- public methods
--##############################################################################

function addon.funnel (eventList, callback)
  local funnelCallback = createFunnelCallback(callback);
  addon.on(eventList, funnelCallback);
  return funnelCallback;
end
