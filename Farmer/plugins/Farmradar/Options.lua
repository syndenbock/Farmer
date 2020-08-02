local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Farm radar'], addon.mainPanel);

local gatherMateBox = panel:addCheckBox(L['show GatherMate nodes']);
local handyNotesBox = panel:addCheckBox(L['show HandyNotes pins']);
local shrinkBox = panel:addCheckBox(L['shrink minimap to radar size']);

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    FarmRadar = {
      showGatherMateNodes = true,
      showHandyNotesPins = true,
      shrinkMinimap = false,
    },
  },
}).vars;

panel:OnLoad(function ()
  local options = saved.farmerOptions.FarmRadar;

  gatherMateBox:SetValue(options.showGatherMateNodes);
  handyNotesBox:SetValue(options.showHandyNotesPins);
  shrinkBox:SetValue(options.shrinkMinimap);
end);

panel:OnSave(function ()
  local options = saved.farmerOptions.FarmRadar;

  options.showGatherMateNodes = gatherMateBox:GetValue();
  options.showHandyNotesPins = handyNotesBox:GetValue();
  options.shrinkMinimap = shrinkBox:GetValue();
end);
