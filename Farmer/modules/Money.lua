local addonName, addon = ...;

local moneyStamp = nil;

addon:on('PLAYER_LOGIN', function ()
  moneyStamp = GetMoney();
end);

addon:on('PLAYER_MONEY', function()
  local money = GetMoney();

  if (moneyStamp == nil or
      farmerOptions.money == false or
      addon.Print.checkHideOptions() == false or
      moneyStamp >= money) then
    moneyStamp = money;
    return;
  end

  local difference = money - moneyStamp;
  local text = GetCoinTextureString(difference);

  moneyStamp = money;

  addon.Print.printMessage(text, {1, 1, 1});
end);
