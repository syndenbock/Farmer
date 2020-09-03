local addonName, addon = ...;

local abs = _G.abs;
local GetMoney = _G.GetMoney;

local L = addon.L;

local panel = addon.OptionClass.Panel:new(L['Money'], addon.mainPanel);

local vars = addon.SavedVariablesHandler(addonName, {'farmerOptions', 'earningStamp'}, {
  farmerOptions = {
    Money = {
      displayMoney = false,
    },
  },
}).vars;

local options = vars.farmerOptions.Money;

panel:mapOptions(options, {
  displayMoney = panel:addCheckBox(L['show money']),
});

addon.on('PLAYER_LOGIN', function ()
    --[[ GetMoney returns 0 when called before PLAYER_LOGIN
         The check for 0 is to fix broken stamps due to this]]
  if (vars.earningStamp == nil or vars.earningStamp == 0) then
    vars.earningStamp = GetMoney();
  end
end);

addon.slash('gold', function (param)
  local money = GetMoney();

  if (param == 'reset') then
    vars.earningStamp = money;
    print(L['Money counter was reset']);
    return;
  end

  local difference = money - vars.earningStamp;
  local text = addon.formatMoney(abs(difference));

  if (difference >= 0) then
    print(L['Money earned this session: '] .. text);
  else
    print(L['Money lost this session: '] .. text);
  end
end);
