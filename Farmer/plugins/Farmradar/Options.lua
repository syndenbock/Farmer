local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Farm radar'], addon.mainPanel);
local gatherMateBox = panel:addCheckBox(L['show GatherMate nodes']);
local handyNotesBox = panel:addCheckBox(L['show HandyNotes pins']);

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    FarmRadar = {
      showGatherMateNodes = true,
      showHandyNotesPins = true,
      showQuestAreas = true,
    }
  },
}).vars;

panel:OnLoad(function ()
  gatherMateBox:SetValue(saved.farmerOptions.FarmRadar.showGatherMateNodes);
  handyNotesBox:SetValue(saved.farmerOptions.FarmRadar.showHandyNotesPins);
end);

panel:OnSave(function ()
  saved.farmerOptions.FarmRadar.showGatherMateNodes = gatherMateBox:GetValue();
  saved.farmerOptions.FarmRadar.showHandyNotesPins = handyNotesBox:GetValue();
end);
