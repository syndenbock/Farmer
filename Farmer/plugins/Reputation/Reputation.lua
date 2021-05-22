local addonName, addon = ...;

if (not addon.isDetectorAvailable('reputation')) then return end

local abs = _G.abs;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local GetFactionInfoByID = _G.GetFactionInfoByID;
local printMessageWithData = addon.Print.printMessageWithData;

local farmerFrame = addon.frame;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Reputation;

local MESSAGE_COLORS = {0, 0.35, 1};
local SUBSPACE = farmerFrame:CreateSubspace();

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

local function getDisplayData (info)
  local previousData = farmerFrame:GetMessageData(SUBSPACE, info.faction);

  if (previousData == nil) then
    return {
      reputationChange = info.reputationChange,
      standingChanged = info.standingChanged,
      paragonLevelGained = info.paragonLevelGained,
    };
  end

  return {
    reputationChange = previousData.reputationChange + info.reputationChange,
    standingChanged = previousData.standingChanged or info.standingChanged,
    paragonLevelGained = previousData.paragonLevelGained or
        info.paragonLevelGained,
  };
end

local function displayReputation (info)
  local displayData = getDisplayData(info);
  local text = BreakUpLargeNumbers(displayData.reputationChange);

  if (displayData.reputationChange > 0) then
    text = '+' .. text;
  end

  if (displayData.standingChanged) then
    local iconPath = 'interface/icons/spell_holy_prayerofmendingtga.blp';

    text = addon.stringJoin({text, addon.getIcon(iconPath),
                             getStandingLabel(info.standing)}, ' ');
  end

  if (displayData.paragonLevelGained) then
    local iconPath = 'interface/icons/inv_treasurechest_felfirecitadel.blp';

    text = addon.stringJoin({text, addon.getIcon(iconPath)}, ' ');
  end

  --[[ could have stored faction name when generating faction info, but we
       can afford getting the name now for saving the memory ]]
  text = GetFactionInfoByID(info.faction) .. ' ' .. text;

  printMessageWithData(SUBSPACE, info.faction, displayData, text,
      MESSAGE_COLORS);
end

addon.listen('REPUTATION_CHANGED', function (reputationInfo)
  if (not checkReputationOptions() or
      not shouldReputationBeDisplayed(reputationInfo)) then
    return;
  end

  displayReputation(reputationInfo);
end);
