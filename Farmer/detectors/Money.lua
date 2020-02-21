local addonName, addon = ...;

local moneyStamp = nil;

addon:on('PLAYER_LOGIN', function ()
  moneyStamp = GetMoney();
end);

addon:on('PLAYER_MONEY', function ()
  if (moneyStamp == nil) then return end

  local money = GetMoney();
  local difference = money - moneyStamp;

  moneyStamp = money;

  addon:yell('MONEY_CHANGED', difference);
end);
