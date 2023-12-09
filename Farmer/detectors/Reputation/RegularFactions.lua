local _, addon = ...;

addon.registerAvailableDetector('reputation');

local floor = _G.floor;
local tinsert = _G.tinsert;

local function returnFalse ()
  return false;
end

local C_Reputation = _G.C_Reputation;
local GetFactionParagonInfo = C_Reputation and C_Reputation.GetFactionParagonInfo;
local IsFactionParagon = C_Reputation.IsFactionParagon or returnFalse;

local GetNumFactions = _G.GetNumFactions;
local GetFactionInfo = _G.GetFactionInfo;
local ExpandFactionHeader = _G.ExpandFactionHeader;
local CollapseFactionHeader = _G.CollapseFactionHeader;

local ImmutableMap = addon.import('Factory/ImmutableMap');

local reputationCache = {};

local function updateParagonInfo (factionInfo)
  if (not IsFactionParagon(factionInfo.faction)) then return end

  local paragonInfo = {GetFactionParagonInfo(factionInfo.faction)};

  if (paragonInfo[1] and paragonInfo[2]) then
    factionInfo.reputation = factionInfo.reputation + paragonInfo[1];
    factionInfo.paragonLevel = floor(paragonInfo[1] / paragonInfo[2]);
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
    name = factionInfo[1],
    faction = factionInfo[14],
    standing = factionInfo[3],
    reputation = factionInfo[6],
    isHeader = factionInfo[9],
    isCollapsed = factionInfo[10],
    hasRep = factionInfo[11],
  };
end

local function iterateReputations (callback)
  local info = {};
  local numFactions = GetNumFactions();
  local expandedIndices = {};
  local index = 1;

  --[[ we have to use a while loop, because a for loop would end when reaching
       the last loop, even when numFactions increases in that loop --]]
  while (index <= numFactions) do
    local factionInfo = packFactionInfo(index);

    if (factionInfo.name == nil) then
      addon.printOneTimeMessage('Could not check factions as another addon seems to be interfering with the reputation pane');
      break;
    end

    if (factionInfo.isHeader and factionInfo.isCollapsed) then
      tinsert(expandedIndices, index);
      ExpandFactionHeader(index);
      numFactions = GetNumFactions();
    end

    if (factionInfo.faction) then
      updateParagonInfo(factionInfo);
      callback(factionInfo);
    end

    index = index + 1;
  end

  collapseExpandedReputations(expandedIndices);

  return info;
end

local function storeReputation (factionInfo)
  local data = {
    reputation = factionInfo.reputation,
    standing = factionInfo.standing,
    paragonLevel = factionInfo.paragonLevel,
  };

  reputationCache[factionInfo.faction] = data;
end

local function initReputationCache ()
  iterateReputations(storeReputation);
end

local function yellReputation (reputationInfo)
  addon.yell('REPUTATION_CHANGED', ImmutableMap(reputationInfo));
end

local function hasParagonLevel (factionInfo)
  return (factionInfo.paragonLevel ~= nil and factionInfo.paragonLevel > 0);
end

local function handleNewReputation (factionInfo)
  if (factionInfo.reputation ~= 0) then
    storeReputation(factionInfo);
    yellReputation({
      name = factionInfo.name,
      faction = factionInfo.faction,
      reputationChange = factionInfo.reputation,
      standing = factionInfo.standing,
      paragonLevel = factionInfo.paragonLevel,
      paragonLevelGained = hasParagonLevel(factionInfo),
      standingChanged = true,
    });
  end
end

local function updateReputation (cachedInfo, factionInfo)
  cachedInfo.reputation = factionInfo.reputation;
  cachedInfo.standing = factionInfo.standing;
  cachedInfo.paragonLevel = factionInfo.paragonLevel;
end

local function wasParagonLevelGained (cachedInfo, factionInfo)
  if (cachedInfo.paragonLevel == nil) then
    return hasParagonLevel(factionInfo);
  else
    return (factionInfo.paragonLevel ~= nil
        and factionInfo.paragonLevel > cachedInfo.paragonLevel);
  end
end

local function handleCachedReputation (cachedInfo, factionInfo)
  if (factionInfo.reputation ~= cachedInfo.reputation) then
    yellReputation({
      faction = factionInfo.faction,
      reputationChange = factionInfo.reputation - cachedInfo.reputation,
      standing = factionInfo.standing,
      paragonLevel = factionInfo.paragonLevel,
      paragonLevelGained = wasParagonLevelGained(cachedInfo, factionInfo),
      standingChanged = (factionInfo.standing ~= cachedInfo.standing),
    });

    updateReputation(cachedInfo, factionInfo);
  end
end

local function checkReputationChange (factionInfo)
  local cachedInfo = reputationCache[factionInfo.faction];

  if (cachedInfo == nil) then
    handleNewReputation(factionInfo);
  else
    handleCachedReputation(cachedInfo, factionInfo);
  end
end

local function checkReputations ()
  iterateReputations(checkReputationChange);
end

addon.onOnce('PLAYER_LOGIN', function ()
  initReputationCache();
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
    paragonLevel = 1,
    paragonLevelGained = true,
    standingChanged = false,
  });
end
