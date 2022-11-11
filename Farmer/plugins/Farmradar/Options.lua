local addonName, addon = ...;

local L = addon.L;

local panel = addon.import('Class/Options/Panel'):new(L['Farm radar'], addon.mainPanel);
local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
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

  addon.import('Factory/Tooltip'):new(box.checkBox, {
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
