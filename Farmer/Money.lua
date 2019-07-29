local addonName, addon = ...;

addon:on('PLAYER_MONEY', function()
  if (farmerOptions.money == false or
      addon.Print.checkHideOptions() == false) then
    return ;
  end

  local money = GetMoney()

  if (addon.vars.moneyStamp >= money) then
    addon.vars.moneyStamp = money;
    return ;
  end

  local difference = money - addon.vars.moneyStamp;
  local text = GetCoinTextureString(difference);

  addon.vars.moneyStamp = money;

  addon.Print.printMessage(text, 1, 1, 1, 1);
end);
