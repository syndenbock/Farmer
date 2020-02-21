local addonName, addon = ...;

addon:listen('MONEY_CHANGED', function (amount)
  if (amount <= 0 or
      farmerOptions.money == false or
      addon.Print:checkHideOptions() == false) then
    return;
  end

  addon.Print.printMessage(GetCoinTextureString(amount), {1, 1, 1});
end);
