local _, addon = ...;

local C_MajorFactions = _G.C_MajorFactions;

if (C_MajorFactions == nil) then return end

local GetMajorFactionData = C_MajorFactions.GetMajorFactionData;

local ImmutableMap = addon.import('Factory/ImmutableMap');

local majorFactionCache = {};

local function iterateMajorFactions (callback)
  for _, factionId in ipairs(C_MajorFactions.GetMajorFactionIDs()) do
    callback(GetMajorFactionData(factionId));
  end
end

local function updateMajorFaction (cachedInfo, majorFactionInfo)
  cachedInfo.renownReputationEarned = majorFactionInfo.renownReputationEarned;
  cachedInfo.renownLevel = majorFactionInfo.renownLevel;
end

local function storeMajorFaction (majorFactionInfo)
  local cachedInfo = {};
  updateMajorFaction(cachedInfo, majorFactionInfo);
  majorFactionCache[majorFactionInfo.factionID] = cachedInfo;
end

local function initMajorFactionCache ()
  iterateMajorFactions(storeMajorFaction);
end

local function yellReputation (reputationInfo)
  addon.yell('REPUTATION_CHANGED', ImmutableMap(reputationInfo));
end

local function checkMajorFaction (majorFactionInfo)
  local cachedInfo = majorFactionCache[majorFactionInfo.factionID];
  local reputationDifference = majorFactionInfo.renownReputationEarned - cachedInfo.renownReputationEarned;
  local renownLevelChanged = (majorFactionInfo.renownLevel ~= cachedInfo.renownLevel);

  --[[ Major faction reputations are just as bugged as everything else in
    Blizzards code so sometimes the renown level actually changes when you get
    renown, sometimes it doesn't]]

  if (renownLevelChanged) then
    local renownDifference = (majorFactionInfo.renownLevel - cachedInfo.renownLevel);

    reputationDifference = reputationDifference + renownDifference * majorFactionInfo.renownLevelThreshold;
  elseif (reputationDifference < 0) then
    reputationDifference = reputationDifference + majorFactionInfo.renownLevelThreshold;
    majorFactionInfo.renownLevel = majorFactionInfo.renownLevel + 1;
    renownLevelChanged = true;
  end

  if (reputationDifference ~= 0) then
    yellReputation({
      name = majorFactionInfo.name,
      factionID = majorFactionInfo.factionID,
      standingChange = reputationDifference,
      renownLevel = majorFactionInfo.renownLevel,
      renownLevelChanged = renownLevelChanged,
    });

    updateMajorFaction(cachedInfo, majorFactionInfo);
  end
end

local function checkMajorFactions ()
  iterateMajorFactions(checkMajorFaction);
end

local function handleRenownLevel (_, factionId, newRenownLevel, oldRenownLevel)
  checkMajorFaction(GetMajorFactionData(factionId));
end

addon.onOnce('PLAYER_LOGIN', function ()
  initMajorFactionCache();
  addon.funnel('CHAT_MSG_COMBAT_FACTION_CHANGE', checkMajorFactions);
  addon.on('MAJOR_FACTION_RENOWN_LEVEL_CHANGED', handleRenownLevel);
end);
