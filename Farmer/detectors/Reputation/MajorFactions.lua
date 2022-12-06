local _, addon = ...;

local C_MajorFactions = _G.C_MajorFactions;

if (C_MajorFactions == nil) then return end

local ImmutableMap = addon.import('Factory/ImmutableMap');

local majorFactionCache = {};

local function iterateMajorFactions (callback)
  for _, factionId in ipairs(C_MajorFactions.GetMajorFactionIDs()) do
    callback(C_MajorFactions.GetMajorFactionData(factionId));
  end
end

local function storeMajorFaction (majorFactionInfo)
  majorFactionCache[majorFactionInfo.factionID] = {
    renownReputationEarned = majorFactionInfo.renownReputationEarned,
    renownLevel = majorFactionInfo.renownLevel,
    renownLevelThreshold = majorFactionInfo.renownLevelThreshold,
  };
end

local function initMajorFactionCache ()
  iterateMajorFactions(storeMajorFaction);
end

local function yellReputation (reputationInfo)
  addon.yell('REPUTATION_CHANGED', ImmutableMap(reputationInfo));
end

local function updateMajorFaction (cachedInfo, majorFactionInfo)
  cachedInfo.renownReputationEarned = majorFactionInfo.renownReputationEarned;
  cachedInfo.renownLevel = majorFactionInfo.renownLevel;
  cachedInfo.renownLevelThreshold = majorFactionInfo.renownLevelThreshold;
end

local function checkMajorFaction (majorFactionInfo)
  local cachedInfo = majorFactionCache[majorFactionInfo.factionID];
  local renownLevelChanged = false;
  local reputationChange =
      majorFactionInfo.renownReputationEarned - cachedInfo.renownReputationEarned;

  if (majorFactionInfo.renownLevel > cachedInfo.renownLevel) then
    renownLevelChanged = true;
    reputationChange = reputationChange + cachedInfo.renownLevelThreshold;
  end

  if (reputationChange ~= 0) then
    yellReputation({
      name = majorFactionInfo.name,
      faction = majorFactionInfo.factionID,
      reputationChange = reputationChange,
      renownLevel = majorFactionInfo.renownLevel,
      renownLevelChanged = renownLevelChanged,
    });

    updateMajorFaction(cachedInfo, majorFactionInfo);
  end
end

local function checkMajorFactions ()
  iterateMajorFactions(checkMajorFaction);
end

addon.onOnce('PLAYER_LOGIN', function ()
  initMajorFactionCache();
  addon.funnel('CHAT_MSG_COMBAT_FACTION_CHANGE', checkMajorFactions);
end);
