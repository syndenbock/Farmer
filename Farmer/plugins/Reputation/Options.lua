local addonName, addon = ...;

local L = addon.L;

local panel = addon.OptionFactory.Panel:New(L['Reputation'], addon.mainPanel);
local reputationBox = panel:addCheckBox(L['show reputation']);
local thresholdSlider = panel:addSlider(1, 100, L['minimum'], '1', '100', 1);

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    reputation = true,
    reputationThreshold = 15,
  },
}).vars;

panel:OnLoad(function ()
  local options = saved.farmerOptions;

  reputationBox:SetValue(options.reputation);
  thresholdSlider:SetValue(options.reputationThreshold);
end);

panel:OnSave(function ()
  local options = saved.farmerOptions;

  options.reputation = reputationBox:GetValue();
  options.reputationThreshold = thresholdSlider:GetValue();
end);
