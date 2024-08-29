local _, addon = ...;

addon.registerAvailableDetector('reputation');

local floor = _G.floor;
local tinsert = _G.tinsert;

local C_Reputation = addon.import('polyfills/C_Reputation');
local GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo;
local IsFactionParagon = C_Reputation.IsFactionParagon;

local GetNumFactions = C_Reputation.GetNumFactions;
local GetFactionDataByIndex = C_Reputation.GetFactionDataByIndex;
local ExpandFactionHeader = C_Reputation.ExpandFactionHeader;
local CollapseFactionHeader = C_Reputation.CollapseFactionHeader;

local ImmutableMap = addon.import('Factory/ImmutableMap');

local reputationCache = {};

local function updateParagonInfo (factionInfo)
  if (not IsFactionParagon(factionInfo.factionID)) then return end

  local paragonInfo = {GetFactionParagonInfo(factionInfo.factionID)};
  local paragonRep = paragonInfo[1];
  local threshold = paragonInfo[2];

  if (paragonRep and threshold) then
    local hasRewardPending = paragonInfo[3];

    factionInfo.currentStanding = factionInfo.currentStanding + paragonRep;
    factionInfo.paragonLevel = floor(paragonInfo[1] / paragonInfo[2]);

    if (hasRewardPending) then
      factionInfo.paragonLevel = factionInfo.paragonLevel + 1;
    end
  end
end

local function collapseExpandedReputations (expandedIndices)
  --[[ the headers have to be collapse from bottom to top, because collapsing
       top ones first would change the index of the lower ones  --]]
  for x = #expandedIndices, 1, -1 do
    CollapseFactionHeader(expandedIndices[x]);
  end
end

local function iterateReputations (callback)
  local info = {};
  local numFactions = GetNumFactions();
  local expandedIndices = {};
  local index = 1;

  --[[ we have to use a while loop, because a for loop would end when reaching
       the last loop, even when numFactions increases in that loop --]]
  while (index <= numFactions) do
    local factionInfo = GetFactionDataByIndex(index);

    if (factionInfo == nil) then
      -- print('factionInfo is nil:', index);
    elseif (factionInfo.name == nil) then
      addon.printOneTimeMessage('Could not check factions as another addon seems to be interfering with the reputation pane');
    else
      if (factionInfo.isHeader and factionInfo.isCollapsed) then
        tinsert(expandedIndices, index);
        ExpandFactionHeader(index);
        numFactions = GetNumFactions();
      end

      if (factionInfo.factionID) then
        updateParagonInfo(factionInfo);
        callback(factionInfo);
      end
    end

    index = index + 1;
  end

  collapseExpandedReputations(expandedIndices);

  return info;
end

local function storeReputation (factionInfo)
  reputationCache[factionInfo.factionID] = {
    reaction = factionInfo.reaction,
    currentStanding = factionInfo.currentStanding,
    paragonLevel = factionInfo.paragonLevel,
  };
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
    factionInfo.reactionChanged = true;
    factionInfo.standingChange = factionInfo.currentStanding;
    factionInfo.paragonLevelGained = hasParagonLevel(factionInfo);

    storeReputation(factionInfo);
    yellReputation(factionInfo);
  end
end

local function updateCachedReputation (cachedInfo, factionInfo)
  cachedInfo.reaction = factionInfo.reaction;
  cachedInfo.currentStanding = factionInfo.currentStanding;
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
  if (factionInfo.currentStanding ~= cachedInfo.currentStanding) then
    factionInfo.reactionChanged =
        (factionInfo.reaction ~= cachedInfo.reaction);
    factionInfo.standingChange =
        factionInfo.currentStanding - cachedInfo.currentStanding;
    factionInfo.paragonLevelGained =
        wasParagonLevelGained(cachedInfo, factionInfo);

    updateCachedReputation(cachedInfo, factionInfo);
    yellReputation(factionInfo);
  end
end

local function checkstandingChange (factionInfo)
  local cachedInfo = reputationCache[factionInfo.factionID];

  if (cachedInfo == nil) then
    handleNewReputation(factionInfo);
  else
    handleCachedReputation(cachedInfo, factionInfo);
  end
end

local function checkReputations ()
  iterateReputations(checkstandingChange);
end

addon.onOnce('PLAYER_LOGIN', function ()
  initReputationCache();
  addon.funnel('CHAT_MSG_COMBAT_FACTION_CHANGE', checkReputations);
end);

--##############################################################################
-- testing
--##############################################################################

addon.import('tests').reputation = function (id)
  local factionID = tonumber(id) or 2170;

  local info = C_Reputation.GetFactionDataByID(factionID)

  info.standingChange = 550;
  info.paragonLevelGained = true;
  info.reactionChanged = false;

  yellReputation(info);
end
