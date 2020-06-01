local addonName, addon = ...;

local L = addon.L;

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

addon:listen('MONEY_CHANGED', function (amount)
  if (amount <= 0 or
      saved.farmerOptions.money == false or
      addon.Print:checkHideOptions() == false) then
    return;
  end

  addon.Print.printMessage(addon:formatMoney(amount), {1, 1, 1});
end);
