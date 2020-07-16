local addonName, addon = ...;

local abs = _G.abs;
local GetMoney = _G.GetMoney;

local L = addon.L;

local panel = addon.OptionFactory.Panel:New(L['Money'], addon.mainPanel);
local moneyBox = panel:addCheckBox(L['show money']);

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    money = false,
  },
});

saved:OnLoad(function (vars)
  --[[ GetMoney is not ready immediately, so we have to call it when variables
       are loaded ]]
  vars.earningStamp = vars.earningStamp or GetMoney();
end);

saved = saved.vars;

panel:OnLoad(function ()
  moneyBox:SetValue(saved.farmerOptions.money);
end);

panel:OnSave(function ()
  saved.farmerOptions.money = moneyBox:GetValue();
end);

addon.slash('gold', function (param)
  local money = GetMoney();

  if (param == 'reset') then
    saved.earningStamp = money;
    print(L['Money counter was reset']);
    return;
  end

  local difference = money - saved.earningStamp;
  local text = addon.formatMoney(abs(difference));

  if (difference >= 0) then
    print(L['Money earned this session: '] .. text);
  else
    print(L['Money lost this session: '] .. text);
  end
end);
