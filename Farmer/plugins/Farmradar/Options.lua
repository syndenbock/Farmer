local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Farm radar'], addon.mainPanel);
local gatherMateBox = panel:addCheckBox(L['show GatherMate nodes']);
local handyNotesBox = panel:addCheckBox(L['show HandyNotes pins']);

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    showGatherMateNodes = true,
    showHandyNotesPins = true,
  },
}).vars;

panel:OnLoad(function ()
  gatherMateBox:SetValue(saved.farmerOptions.showGatherMateNodes);
  handyNotesBox:SetValue(saved.farmerOptions.showHandyNotesPins);
end);

panel:OnSave(function ()
  saved.farmerOptions.showGatherMateNodes = gatherMateBox:GetValue();
  saved.farmerOptions.showHandyNotesPins = handyNotesBox:GetValue();
end);
