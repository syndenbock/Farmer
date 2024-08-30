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

local C_GossipInfo = _G.C_GossipInfo;
local GetFriendshipReputation = C_GossipInfo.GetFriendshipReputation;
local GetFriendshipReputationRanks = C_GossipInfo.GetFriendshipReputationRanks;

local ImmutableMap = addon.import('Factory/ImmutableMap');

local reputationCache = {};

local function updateParagonInfo (factionInfo)
  if (not IsFactionParagon(factionInfo.factionID)) then return end

  local paragonInfo = {GetFactionParagonInfo(factionInfo.factionID)};
  local paragonReputation = paragonInfo[1];
  local reputationThreshold = paragonInfo[2];

  if (paragonReputation and reputationThreshold) then
    local hasRewardPending = paragonInfo[3];

    factionInfo.currentStanding = factionInfo.currentStanding + paragonReputation;
    factionInfo.paragonLevel = floor(paragonReputation / reputationThreshold);

    if (hasRewardPending) then
      factionInfo.paragonLevel = factionInfo.paragonLevel + 1;
    end
  end
end

local function updateFriendShipInfo (factionInfo)
  local info = GetFriendshipReputation(factionInfo.factionID);

  if (info == nil) then return end

  factionInfo.friendReaction = info.reaction;
  factionInfo.friendRank =
      GetFriendshipReputationRanks(factionInfo.factionID).currentLevel;
  factionInfo.currentStanding = factionInfo.currentStanding + info.standing;
  factionInfo.icon = info.texture;
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
        updateFriendShipInfo(factionInfo);
        callback(factionInfo);
      end
    end

    index = index + 1;
  end

  collapseExpandedReputations(expandedIndices);

  return info;
end

local function updateCachedReputation (cachedInfo, factionInfo)
  cachedInfo.reaction = factionInfo.reaction;
  cachedInfo.currentStanding = factionInfo.currentStanding;
  cachedInfo.paragonLevel = factionInfo.paragonLevel;
  cachedInfo.friendRank = factionInfo.friendRank;
end

local function initCachedReputation (factionInfo)
  local cachedInfo = {};
  updateCachedReputation(cachedInfo, factionInfo);
  reputationCache[factionInfo.factionID] = cachedInfo;
end

local function initReputationCache ()
  iterateReputations(initCachedReputation);
end

local function yellReputation (reputationInfo)
  addon.yell('REPUTATION_CHANGED', ImmutableMap(reputationInfo));
end

local function handleNewReputation (factionInfo)
  if (factionInfo.reputation ~= 0) then
    factionInfo.standingChange = factionInfo.currentStanding;

    if (factionInfo.paragonLevel) then
      factionInfo.paragonLevelGained = true;
    elseif (factionInfo.friendRank) then
      factionInfo.friendshipChanged = true;
    else
      factionInfo.reactionChanged = true;
    end

    initCachedReputation(factionInfo);
    yellReputation(factionInfo);
  end
end

local function handleCachedReputation (cachedInfo, factionInfo)
  if (factionInfo.currentStanding ~= cachedInfo.currentStanding) then
    factionInfo.reactionChanged =
        (factionInfo.reaction ~= cachedInfo.reaction);
    factionInfo.standingChange =
        factionInfo.currentStanding - cachedInfo.currentStanding;
    factionInfo.paragonLevelGained =
        (factionInfo.paragonLevel ~= cachedInfo.paragonLevel);
    factionInfo.friendshipChanged =
        (factionInfo.friendRank ~= cachedInfo.friendRank);

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

  local info = C_Reputation.GetFactionDataByID(factionID);

  updateParagonInfo(info);
  updateFriendShipInfo(info);

  info.standingChange = 550;

  if (info.paragonLevel) then
    info.paragonLevelGained = true;
  elseif (info.friendRank) then
    info.friendshipChanged = true;
  else
    info.reactionChanged = true;
  end

  yellReputation(info);
end
