local _, addon = ...;

addon.registerAvailableDetector('reputation');

local floor = _G.floor;
local tinsert = _G.tinsert;
local C_Reputation = _G.C_Reputation;
local GetFactionParagonInfo = C_Reputation and C_Reputation.GetFactionParagonInfo;
local IsFactionParagon = C_Reputation and C_Reputation.IsFactionParagon;
local GetNumFactions = _G.GetNumFactions;
local GetFactionInfo = _G.GetFactionInfo;
local ExpandFactionHeader = _G.ExpandFactionHeader;
local CollapseFactionHeader = _G.CollapseFactionHeader;

local ImmutableMap = addon.import('Factory/ImmutableMap');

local reputationCache;

local function readParagonInfo (data, faction)
  if (not IsFactionParagon or not IsFactionParagon(faction)) then return end

  local paragonInfo = {GetFactionParagonInfo(faction)};

  if (paragonInfo[1] and paragonInfo[2]) then
    data.paragonReputation = paragonInfo[1];
    data.paragonLevel = floor(paragonInfo[1] / paragonInfo[2]);
  end
end

local function collapseExpandedReputations (expandedIndices)
  --[[ the headers have to be collapse from bottom to top, because collapsing
       top ones first would change the index of the lower ones  --]]
  for x = #expandedIndices, 1, -1 do
    CollapseFactionHeader(expandedIndices[x]);
  end
end

local function packFactionInfo (index)
  local factionInfo = {GetFactionInfo(index)};

  return {
    faction = factionInfo[14],
    standing = factionInfo[3],
    reputation = factionInfo[6],
    isHeader = factionInfo[9],
    isCollapsed = factionInfo[10],
    hasRep = factionInfo[11],
  };
end

local function getReputationInfo ()
  local info = {};
  local numFactions = GetNumFactions();
  local expandedIndices = {};
  local i = 1;

  --[[ we have to use a while loop, because a for loop would end when reaching
       the last loop, even when numFactions increases in that loop --]]
  while (i <= numFactions) do
    local factionInfo = packFactionInfo(i);

    if (factionInfo.isHeader and factionInfo.isCollapsed) then
      tinsert(expandedIndices, i);
      ExpandFactionHeader(i);
      numFactions = GetNumFactions();
    end

    if (factionInfo.hasRep or not factionInfo.isHeader) then
      local data = {
        reputation = factionInfo.reputation,
        standing = factionInfo.standing,
      };

      readParagonInfo(data, factionInfo.faction);
      info[factionInfo.faction] = data;
    end

    i = i + 1;
  end

  collapseExpandedReputations(expandedIndices);

  return info;
end

local function yellReputation (reputationInfo)
  addon.yell('REPUTATION_CHANGED', ImmutableMap(reputationInfo));
end

local function getDifferenceFromCache (cache, info, key)
  if (cache == nil) then
    return info[key] or 0;
  else
    return (info[key] or 0) - (cache[key] or 0);
  end
end

local function checkReputationChange (faction, factionInfo)
  local cachedInfo = reputationCache[faction];
  local reputationChange =
      getDifferenceFromCache(cachedInfo, factionInfo, 'reputation') +
      getDifferenceFromCache(cachedInfo, factionInfo, 'paragonReputation');

  if (reputationChange ~= 0) then
    yellReputation({
      faction = faction,
      reputationChange = reputationChange,
      standing = factionInfo.standing,
      paragonLevelGained =
          (getDifferenceFromCache(cachedInfo, factionInfo, 'paragonLevel') > 0),
      standingChanged = (factionInfo.standing ~= cachedInfo.standing),
    });
  end
end

local function checkReputations ()
  local repInfo = getReputationInfo();

  for faction, factionInfo in pairs(repInfo) do
    checkReputationChange(faction, factionInfo);
  end

  reputationCache = repInfo;
end

addon.onOnce('PLAYER_LOGIN', function ()
  reputationCache = getReputationInfo();
  addon.funnel('CHAT_MSG_COMBAT_FACTION_CHANGE', checkReputations);
end);


--##############################################################################
-- testing
--##############################################################################

addon.import('tests').reputation = function (id)
  local faction = tonumber(id) or 2170;

  yellReputation({
    faction = faction,
    reputationChange = 550,
    standing = 5,
    paragonLevelGained = true,
    standingChanged = false,
  });
end
