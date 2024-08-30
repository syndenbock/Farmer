local addonName, addon = ...;

if (not addon.isDetectorAvailable('reputation')) then return end

local abs = _G.abs;
local GetText = _G.GetText;
local UnitSex = _G.UnitSex;

local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local printIconMessageWithData = addon.Print.printIconMessageWithData;

local stringJoin = addon.stringJoin;
local farmerFrame = addon.frame;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Reputation;

local MESSAGE_COLORS = {r = 0, g = 0.35, b = 1};
local SUBSPACE = farmerFrame:CreateSubspace();

local function getStandingLabel (standing)
  return GetText('FACTION_STANDING_LABEL' .. standing, UnitSex('player'));
end

local function checkReputationOptions ()
  return (options.displayReputation == true and
          addon.Print.checkHideOptions());
end

local function shouldReputationBeDisplayed (info)
  return (info.reactionChanged or
          info.paragonLevelGained or
          abs(info.standingChange) > options.reputationThreshold);
end

local function getDisplayData (info)
  local previousData = farmerFrame:GetMessageData(SUBSPACE, info.factionID);

  if (previousData == nil) then
    return info;
  end

  return {
    name = info.name,
    standingChange = previousData.standingChange + info.standingChange,
    reactionChanged = previousData.reactionChanged or info.reactionChanged,
    paragonLevelGained = previousData.paragonLevelGained or
        info.paragonLevelGained,
    renownLevelChanged =
        previousData.renownLevelChanged or info.renownLevelChanged,
    friendshipChanged = previousData.friendshipChanged or info.friendshipChanged,
  };
end

local function displayReputation (info)
  local displayData = getDisplayData(info);
  local text = BreakUpLargeNumbers(displayData.standingChange);
  local icon;

  if (displayData.standingChange > 0) then
    text = '+' .. text;
  end

  if (displayData.paragonLevelGained) then
    icon = 'interface/icons/inv_treasurechest_felfirecitadel.blp';
  elseif (displayData.reactionChanged) then
    icon = 'interface/icons/spell_holy_prayerofmendingtga.blp';
    text = stringJoin(' ', text, getStandingLabel(info.reaction));
  elseif (displayData.renownLevelChanged) then
    icon = 'interface/icons/spell_holy_prayerofmendingtga.blp';
    text = stringJoin('', text, ' (', info.renownLevel, ')');
  elseif (displayData.friendshipChanged) then
    icon = info.icon;
    text = stringJoin('', text, ' (', info.friendReaction, ')');
  end

  --[[ could have stored faction name when generating faction info, but we
       can afford getting the name now for saving the memory ]]
  text = info.name .. ' ' .. text;

  printIconMessageWithData(SUBSPACE, info.factionID, displayData, icon, text,
      MESSAGE_COLORS);
end

addon.listen('REPUTATION_CHANGED', function (reputationInfo)
  if (checkReputationOptions() and
      shouldReputationBeDisplayed(reputationInfo)) then
    displayReputation(reputationInfo);
  end
end);
