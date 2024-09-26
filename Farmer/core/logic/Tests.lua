local addonName, addon = ...;

local SlashCommands = addon.import('core/logic/SlashCommands');
local Strings = addon.import('core/utils/Strings');

local module = addon.export('core/logic/Tests', {});

local tests = {};

function module.addTest (testName, callback)
  assert(tests[testName] == nil, 'Test already exists: ' .. testName);
  tests[testName] = callback;
end

module.addTest('memory', function(_addonName)
  local usage;

  _addonName = _addonName or addonName;
  _G.collectgarbage()
  _G.UpdateAddOnMemoryUsage();
  usage = _G.BreakUpLargeNumbers(_G.GetAddOnMemoryUsage(_addonName));

  print(_addonName, 'uses', usage .. 'kb of memory');
end);

local function printAvailableTests ()
  Strings.printAddonMessage('Available tests:');
  for name in pairs(tests) do
    print(name);
  end
end

local function executeTest (name, ...)
  local test = tests[name];

  if (test) then
    test(...);
  else
    Strings.printAddonMessage('Unknown test:', name);
  end
end

SlashCommands.addCommand('test', function (name, ...)
  if (name == nil) then
    printAvailableTests();
  else
    executeTest(name, ...);
  end
end);
