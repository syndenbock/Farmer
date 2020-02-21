local addonName, addon = ...

local L = addon.L

addon.vars = {}

--[[
///#############################################################################
/// proxy
///#############################################################################
--]]
do
  local proxy = {}

  function proxy:__index (key)
    return proxy[key]
  end

  function proxy:__newindex (key, value)
    if (proxy[key] ~= nil) then
      error(addonName .. ': addon key already in use: ' .. key)
    end
    proxy[key] = value
  end

  function proxy:__index (key)
    if (proxy[key] == nil) then
      error(addonName .. ': addon key does not exist: ' .. key)
    end

    return proxy[key]
  end

  setmetatable(addon, proxy)
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
