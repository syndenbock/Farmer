local addonName, addon = ...;

local abs = _G.abs;
local GetMoney = _G.GetMoney;

local L = addon.L;

local panel = addon.OptionClass.Panel:new(L['Money'], addon.mainPanel);

local saved = addon.SavedVariablesHandler(addonName, {'farmerOptions', 'earningStamp'}, {
  farmerOptions = {
    money = false,
  },
});

local options = saved.vars.farmerOptions;

saved:OnLoad(function (vars)
  --[[ GetMoney is not ready immediately, so we have to call it when variables
       are loaded ]]
  vars.earningStamp = vars.earningStamp or GetMoney();
end);

panel:mapOptions(options, {
  money = panel:addCheckBox(L['show money']),
});

addon.slash('gold', function (param)
  local money = GetMoney();

  if (param == 'reset') then
    saved.vars.earningStamp = money;
    print(L['Money counter was reset']);
    return;
  end

  local difference = money - saved.vars.earningStamp;
  local text = addon.formatMoney(abs(difference));

  if (difference >= 0) then
    print(L['Money earned this session: '] .. text);
  else
    print(L['Money lost this session: '] .. text);
  end
end);
