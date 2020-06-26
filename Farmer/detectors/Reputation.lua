local _, addon = ...;

if (addon:isClassic()) then return end

local floor = _G.floor;
local C_Reputation = _G.C_Reputation;
local GetFactionParagonInfo = C_Reputation and C_Reputation.GetFactionParagonInfo or nil;
local IsFactionParagon = C_Reputation and C_Reputation.IsFactionParagon or nil;
local GetNumFactions = _G.GetNumFactions;
local GetFactionInfo = _G.GetFactionInfo;
local ExpandFactionHeader = _G.ExpandFactionHeader;
local CollapseFactionHeader = _G.CollapseFactionHeader;

local reputationCache;

local function getRepInfo ()
  local info = {};
  local numFactions = GetNumFactions();
  local expandedIndices = {};
  local expandCount = 0;
  local i = 1;

  --[[ we have to use a while loop, because a for loop would end when reaching
       the last loop, even when numFactions increases in that loop --]]
  while (i <= numFactions) do
    local factionInfo = {GetFactionInfo(i)};

    local faction = factionInfo[14];
    local standing = factionInfo[3];
    local reputation = factionInfo[6];
    local isHeader = factionInfo[9];
    local isCollapsed = factionInfo[10];
    local hasRep = factionInfo[11];

    if (isHeader and isCollapsed) then
      expandCount = expandCount + 1;
      expandedIndices[expandCount] = i;
      ExpandFactionHeader(i);
      numFactions = GetNumFactions();
    end

    if (hasRep or not isHeader) then
      local data = {
        reputation = reputation,
        standing = standing,
      };

      if (IsFactionParagon and IsFactionParagon(faction)) then
        local paragonInfo = {GetFactionParagonInfo(faction)};

        if (paragonInfo[1] and paragonInfo[2]) then
          data.paragonReputation = paragonInfo[1];
          data.paragonLevel = floor(paragonInfo[1] / paragonInfo[2]);
        end
      end

      info[faction] = data;
    end

    i = i + 1;
  end

  --[[ the headers have to be collapse from bottom to top, because collapsing
       top ones first would change the index of the lower ones  --]]
  for x = expandCount, 1, -1 do
    CollapseFactionHeader(expandedIndices[x]);
  end

  return info;
end

local function checkReputationChanges ()
  if (not reputationCache) then return end

  local repInfo = getRepInfo();

  for faction, factionInfo in pairs(repInfo) do
    local cachedFactionInfo = reputationCache[faction] or {};

    local function getCacheDifference (key)
      return (factionInfo[key] or 0) - (cachedFactionInfo[key] or 0);
    end

    local paragonRepChange = getCacheDifference('paragonReputation');
    local paragonLevelGained = (getCacheDifference('paragonLevel') > 0);
    local repChange = getCacheDifference('reputation') + paragonRepChange;

    if (repChange ~= 0) then
      addon:yell('REPUTATION_CHANGED', {
        faction = faction,
        reputationChange = repChange,
        standing = factionInfo.standing,
        paragonLevelGained = paragonLevelGained,
        standingChanged = (factionInfo.standing ~= cachedFactionInfo.standing),
      });
    end
  end

  reputationCache = repInfo;
end

addon:on('PLAYER_LOGIN', function ()
  reputationCache = getRepInfo();
end);

addon:funnel('CHAT_MSG_COMBAT_FACTION_CHANGE', checkReputationChanges);
