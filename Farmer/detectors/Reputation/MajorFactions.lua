local _, addon = ...;

local C_MajorFactions = _G.C_MajorFactions;

local ImmutableMap = addon.import('Factory/ImmutableMap');

local majorFactionCache = {};

local function iterateMajorFactions (callback)
  for _, factionId in ipairs(C_MajorFactions.GetMajorFactionIDs()) do
    callback(C_MajorFactions.GetMajorFactionData(factionId));
  end
end

local function initMajorFactionCache ()
  iterateMajorFactions(function (majorFactionInfo)
    majorFactionCache[majorFactionInfo.factionID] = majorFactionInfo;
  end);
end

local function yellReputation (reputationInfo)
  addon.yell('REPUTATION_CHANGED', ImmutableMap(reputationInfo));
end

local function checkMajorFaction (majorFactionInfo)
  local cachedInfo = majorFactionCache[majorFactionInfo.factionID];

  if (cachedInfo.renownReputationEarned ~=
      majorFactionInfo.renownReputationEarned) then
    majorFactionCache[majorFactionInfo.factionID] = majorFactionInfo;

    yellReputation({
      faction = majorFactionInfo.factionID,
      reputationChange = majorFactionInfo.renownReputationEarned -
          cachedInfo.renownReputationEarned,
    });
  end
end

local function checkMajorFactions ()
  iterateMajorFactions(checkMajorFaction);
end

addon.onOnce('PLAYER_LOGIN', function ()
  initMajorFactionCache();
  addon.funnel('CHAT_MSG_COMBAT_FACTION_CHANGE', checkMajorFactions);
end);
