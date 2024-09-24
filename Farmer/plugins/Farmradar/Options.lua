local addonName, addon = ...;

local L = addon.L;

local SavedVariables = addon.import('client/utils/SavedVariables');
local Panel = addon.import('client/classes/options/Panel');
local Options = addon.import('main/Options');

local panel = Panel:new(L['Farm radar'], Options.mainPanel);
local options = SavedVariables.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    FarmRadar = {
      enableAddonNodeTooltips = false,
      enableDefaultNodeTooltips = false,
      shrinkMinimap = false,
    },
  },
}).vars.farmerOptions.FarmRadar;

local function createDefaultNodeOptionBox ()
  local box = panel:addCheckBox( L['enable tooltips for default nodes']);

  addon.import('client/classes/Tooltip'):new(box.checkBox, {
    L['This will block all mouseovers under the minimap in farm mode!'],
    L['It\'s recommended to enable shrinking the minimap when enabling this'],
  });

  return box;
end

panel:mapOptions(options, {
  enableAddonNodeTooltips = panel:addCheckBox(L['show addon node tooltips']),
  enableDefaultNodeTooltips = createDefaultNodeOptionBox(),
  shrinkMinimap = panel:addCheckBox(L['shrink minimap to radar size']),
});
