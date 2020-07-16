local _, addon = ...;

local tests = addon.share('tests');

function tests.testNextFrame ()
  local GetTime = _G.GetTime;
  local time = GetTime();

  print(time);

  _G.C_Timer.After(0, function ()
    print('C_Timer', GetTime());
  end);

  addon.executeOnNextFrame(function ()
    print('OnUpdate', GetTime());
  end);
end

function tests.memory (addonName)
  _G.collectgarbage()
  _G.UpdateAddOnMemoryUsage();
  print(_G.BreakUpLargeNumbers(_G.GetAddOnMemoryUsage(addonName)));
end

addon.slash('test', function (name, ...)
  local test = tests[name];

  if (test) then
    test(...);
  else
    print('unknown test:', name);
  end
end);
