local addonName, addon = ...;

if (not addon.isDetectorAvailable('money')) then return end

local abs = _G.abs;
local GetMoney = _G.GetMoney;

local L = addon.L;

local panel = addon.import('Class/Options/Panel'):new(L['Money'], addon.mainPanel);

local vars = addon.SavedVariablesHandler(addonName, {'farmerOptions', 'farmerCharOptions'}, {
  farmerOptions = {
    Money = {
      displayMoney = false,
    },
  },
  farmerCharOptions = {
    Money = {};
  },
}).vars;

local options = vars.farmerOptions.Money;
local charOptions = vars.farmerCharOptions.Money;

panel:mapOptions(options, {
  displayMoney = panel:addCheckBox(L['show money']),
});

addon.onOnce('PLAYER_LOGIN', function ()
    --[[ GetMoney returns 0 when called before PLAYER_LOGIN ]]
  if (charOptions.earningStamp == nil) then
    charOptions.earningStamp = GetMoney();
  end
end);

addon.slash('gold', function (param)
  local money = GetMoney();

  if (param == 'reset') then
    charOptions.earningStamp = money;
    addon.printAddonMessage(L['Money counter was reset']);
    return;
  end

  local difference = money - charOptions.earningStamp;
  local text = addon.formatMoney(abs(difference));

  if (difference >= 0) then
    addon.printAddonMessage(L['Money earned this session: '] .. text);
  else
    addon.printAddonMessage(L['Money lost this session: '] .. text);
  end
end);
