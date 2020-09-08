local addonName, addon = ...;

local abs = _G.abs;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local GetFactionInfoByID = _G.GetFactionInfoByID;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Reputation;

local MESSAGE_COLORS = {0, 0.35, 1};

local function getStandingLabel (standing)
  local labelPrefix = 'FACTION_STANDING_LABEL';

  return _G[labelPrefix .. standing];
end

local function checkReputationOptions ()
  return (options.displayReputation == true and
          addon.Print.checkHideOptions());
end

local function shouldReputationBeDisplayed (info)
  return (info.standingChanged or
          info.paragonLevelGained or
          abs(info.reputationChange) > options.reputationThreshold);
end

local function displayReputation (info)
  local repChange = info.reputationChange;
  local text = BreakUpLargeNumbers(repChange);

  if (repChange > 0) then
    text = '+' .. text;
  end

  if (info.standingChanged) then
    local iconPath = 'interface/icons/spell_holy_prayerofmendingtga.blp';

    text = addon.stringJoin({text, addon.getIcon(iconPath),
                             getStandingLabel(info.standing)}, ' ');
  end

  if (info.paragonLevelGained) then
    local iconPath = 'interface/icons/inv_treasurechest_felfirecitadel.blp';

    text = addon.stringJoin({text, addon.getIcon(iconPath)}, ' ');
  end

  --[[ could have stored faction name when generating faction info, but we
       can afford getting the name now for saving the memory ]]
  text = GetFactionInfoByID(info.faction) .. ' ' .. text;

  addon.Print.printMessage(text, MESSAGE_COLORS);
end

addon.listen('REPUTATION_CHANGED', function (reputationInfo)
  if (not checkReputationOptions() or
      not shouldReputationBeDisplayed(reputationInfo)) then
    return;
  end

  displayReputation(reputationInfo);
end);
