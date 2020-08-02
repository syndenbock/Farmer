local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Farm radar'], addon.mainPanel);

local gatherMateBox = panel:addCheckBox(L['show GatherMate nodes']);
local handyNotesBox = panel:addCheckBox(L['show HandyNotes pins']);
local defaultNodeBox = panel:addCheckBox(L['enable tooltips for default nodes']);
local shrinkBox = panel:addCheckBox(L['shrink minimap to radar size']);

addon.Factory.Tooltip:new(defaultNodeBox.checkBox, {
  L['This will block all mouseovers under the minimap in farm mode!'],
  L['It\'s recommended to enable shrinking the minimap when enabling this'],
});

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    FarmRadar = {
      showGatherMateNodes = true,
      showHandyNotesPins = true,
      enableDefaultNodeTooltips = false,
      shrinkMinimap = false,
    },
  },
}).vars.farmerOptions.FarmRadar;

panel:OnLoad(function ()
  gatherMateBox:SetValue(options.showGatherMateNodes);
  handyNotesBox:SetValue(options.showHandyNotesPins);
  defaultNodeBox:SetValue(options.enableDefaultNodeTooltips);
  shrinkBox:SetValue(options.shrinkMinimap);
end);

panel:OnSave(function ()
  options.showGatherMateNodes = gatherMateBox:GetValue();
  options.showHandyNotesPins = handyNotesBox:GetValue();
  options.enableDefaultNodeTooltips = defaultNodeBox:GetValue();
  options.shrinkMinimap = shrinkBox:GetValue();
end);
