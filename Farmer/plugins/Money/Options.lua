local addonName, addon = ...;

if (not addon.isDetectorAvailable('money')) then return end

local abs = _G.abs;
local GetMoney = _G.GetMoney;

local Events = addon.import('core/logic/Events');
local SlashCommands = addon.import('core/logic/SlashCommands');
local Strings = addon.import('core/utils/Strings');
local Panel = addon.import('client/classes/options/Panel');
local SavedVariables = addon.import('client/utils/SavedVariables');
local Options = addon.import('main/Options');
local L = addon.L;

local panel = Panel:new(L['Money'], Options.panel);

local vars = SavedVariables.SavedVariablesHandler(addonName, {'farmerOptions', 'farmerCharOptions'}, {
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

Events.onOnce('PLAYER_LOGIN', function ()
    --[[ GetMoney returns 0 when called before PLAYER_LOGIN ]]
  if (charOptions.earningStamp == nil) then
    charOptions.earningStamp = GetMoney();
  end
end);

SlashCommands.addCommand('gold', function (param)
  local money = GetMoney();

  if (param == 'reset') then
    charOptions.earningStamp = money;
    Strings.printAddonMessage(L['Money counter was reset']);
    return;
  end

  local difference = money - charOptions.earningStamp;
  local text = Strings.formatMoney(abs(difference));

  if (difference >= 0) then
    Strings.printAddonMessage(L['Money earned this session: '] .. text);
  else
    Strings.printAddonMessage(L['Money lost this session: '] .. text);
  end
end);
