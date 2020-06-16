local addonName, addon = ...;

local tests = {};

function tests.testItems (id, count)
  if (id) then
    id = tonumber(id);
    local _, link = GetItemInfo(id);

    count = tonumber(count or 1);

    addon:yell('NEW_ITEM', id, link, count);
    return;
  end

  local testItems = {
    2447, -- Peacebloom
    4496, -- Small Brown Pouch
    6975, -- Whirlwind Axe
    4322, -- Enchanter's Cowl
    13521, -- Recipe: Flask of Supreme Power
  };

  for i = 1, #testItems, 1 do
    local id = testItems[i];
    local _, link = GetItemInfo(id);

    addon:yell('NEW_ITEM', id, link, 1);
    addon:yell('NEW_ITEM', id, link, 4);
  end
end

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
