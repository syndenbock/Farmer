local _, addon = ...;

local GetMoney = _G.GetMoney;

local Events = addon.import('core/logic/Events');
local Yell = addon.import('core/logic/Yell');

addon.registerAvailableDetector('money');

local moneyStamp;

Events.onOnce('PLAYER_LOGIN', function ()
  moneyStamp = GetMoney();

  Events.funnel('PLAYER_MONEY', function ()
    if (not moneyStamp) then return end

    local money = GetMoney();
    local difference = money - moneyStamp;

    moneyStamp = money;

    Yell.yell('MONEY_CHANGED', difference);
  end);
end);

local Tests = addon.import('core/logic/Tests');

Tests.addTest('money', function ()
  Yell.yell('MONEY_CHANGED', 12390);
end);
