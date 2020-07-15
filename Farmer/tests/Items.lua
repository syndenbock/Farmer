local _, addon = ...;

local tests = addon:share('tests');

function tests.testReputation ()
  addon:yell('REPUTATION_CHANGED', {
    faction = 2170,
    reputationChange = 550,
    standing = 5,
    paragonLevelGained = true,
    standingChanged = false,
  });
end

function tests.testCurrency ()
  addon:yell('CURRENCY_CHANGED', 1755, 1500, 15357);
end

function tests.testNextFrame ()
  local time = GetTime();

  print(time);

  C_Timer.After(0, function ()
    print('C_Timer', GetTime());
  end);

  addon:executeOnNextFrame(function ()
    print('OnUpdate', GetTime());
  end);
end

function tests.memory (addon)
  collectgarbage()
  UpdateAddOnMemoryUsage();
  print(BreakUpLargeNumbers(GetAddOnMemoryUsage(addon)));
end

addon:slash('test', function (name, ...)
  local test = tests[name] or tests.testItems;

  test(...);
end);
