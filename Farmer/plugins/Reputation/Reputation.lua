local addonName, addon = ...;

if (not addon.isDetectorAvailable('reputation')) then return end

local abs = _G.abs;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local GetFactionInfoByID = _G.GetFactionInfoByID;
local printIconMessageWithData = addon.Print.printIconMessageWithData;

local farmerFrame = addon.frame;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Reputation;

local MESSAGE_COLORS = {r = 0, g = 0.35, b = 1};
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
    return info;
  end

  return {
    reputationChange = previousData.reputationChange + info.reputationChange,
    standingChanged = previousData.standingChanged or info.standingChanged,
    paragonLevelGained = previousData.paragonLevelGained or
        info.paragonLevelGained,
    renownLevelChanged =
        previousData.renownLevelChanged or info.renownLevelChanged,
  };
end

local function displayReputation (info)
  local displayData = getDisplayData(info);
  local text = BreakUpLargeNumbers(displayData.reputationChange);
  local icon;

  if (displayData.reputationChange > 0) then
    text = '+' .. text;
  end

  if (displayData.paragonLevelGained) then
    icon = 'interface/icons/inv_treasurechest_felfirecitadel.blp';
  elseif (displayData.standingChanged) then
    icon = 'interface/icons/spell_holy_prayerofmendingtga.blp';

    text = addon.stringJoin({text, getStandingLabel(info.standing)}, ' ');
  elseif (displayData.renownLevelChanged) then
    icon = 'interface/icons/spell_holy_prayerofmendingtga.blp';

    text = text .. ' (' .. info.renownLevel .. ')';
  end

  --[[ could have stored faction name when generating faction info, but we
       can afford getting the name now for saving the memory ]]
  text = GetFactionInfoByID(info.faction) .. ' ' .. text;

  printIconMessageWithData(SUBSPACE, info.faction, displayData, icon, text,
      MESSAGE_COLORS);
end

addon.listen('REPUTATION_CHANGED', function (reputationInfo)
  if (checkReputationOptions() and
      shouldReputationBeDisplayed(reputationInfo)) then
    displayReputation(reputationInfo);
  end
end);
