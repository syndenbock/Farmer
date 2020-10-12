local addonName, addon = ...;

local tests = addon.share('tests');

function tests.memory (_addonName)
  local usage;

  _addonName = _addonName or addonName;
  _G.collectgarbage()
  _G.UpdateAddOnMemoryUsage();
  usage = _G.BreakUpLargeNumbers(_G.GetAddOnMemoryUsage(_addonName));

  print(_addonName, 'uses', usage .. 'kb of memory');
end

local function printAvailableTests ()
  print(addonName .. ': available tests:');
  for name in pairs(tests) do
    print(name);
  end
end

local function executeTest (name, ...)
  local test = tests[name];

  if (test) then
    test(...);
  else
    print('unknown test:', name);
  end
end

addon.slash('test', function (name, ...)
  if (name == nil) then
    printAvailableTests();
  else
    executeTest(name, ...);
  end
end);
