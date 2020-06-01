local addonName, addon = ...;

local abs = _G.abs;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local GetFactionInfoByID = _G.GetFactionInfoByID;

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

local MESSAGE_COLORS = {0, 0.35, 1};

local function getStandingLabel (standing)
  local labelPrefix = 'FACTION_STANDING_LABEL';

  return _G[labelPrefix .. standing];
end

addon:listen('REPUTATION_CHANGED', function (data)
  if (saved.farmerOptions.reputation == false or
      addon.Print.checkHideOptions() == false) then
    return;
  end

  local threshold = saved.farmerOptions.reputationThreshold;
  local repChange = data.reputationChange;
  local standingChanged = data.standingChanged;
  local paragonLevelGained = data.paragonLevelGained;
  local text = BreakUpLargeNumbers(repChange);

  if (standingChanged or
      paragonLevelGained or
      (abs(repChange) > threshold)) then
    if (repChange > 0) then
      text = '+' .. text;
    end

    if (standingChanged) then
      local iconPath = 'interface/icons/spell_holy_prayerofmendingtga.blp';

      text = addon:stringJoin({text, addon:getIcon(iconPath), getStandingLabel(data.standing)}, ' ');
    end

    if (paragonLevelGained) then
      local iconPath = 'interface/icons/inv_treasurechest_felfirecitadel.blp';

      text = addon:stringJoin({text, addon:getIcon(iconPath)}, ' ');
    end

    --[[ could have stored faction name when generating faction info, but we
         can afford getting the name now for saving the memory ]]
    text = GetFactionInfoByID(data.faction) .. ' ' .. text;

    addon.Print.printMessage(text, MESSAGE_COLORS);
  end
end);
