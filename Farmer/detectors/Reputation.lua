local addonName, addon = ...;

local GetFactionParagonInfo = C_Reputation and C_Reputation.GetFactionParagonInfo or nil;
local IsFactionParagon = C_Reputation and C_Reputation.IsFactionParagon or nil;

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
      local data = {};

      data.reputation = reputation;

      if (IsFactionParagon ~= nil and IsFactionParagon(faction)) then
        local paragonInfo = {GetFactionParagonInfo(faction)};

        if (paragonInfo[1] ~= nil and paragonInfo[2] ~= nil) then
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
  for i = expandCount, 1, -1 do
    CollapseFactionHeader(expandedIndices[i]);
  end

  return info;
end

local function checkReputationChanges ()
  if (reputationCache == nil) then return end

  local repInfo = getRepInfo();

  for faction, factionInfo in pairs(repInfo) do
    local cachedFactionInfo = reputationCache[faction] or {};

    local function getCacheDifference (key)
      return (factionInfo[key] or 0) - (cachedFactionInfo[key] or 0);
    end

    local repChange = getCacheDifference('reputation');
    local paragonLevelGained = false;

    if (factionInfo.paragonReputation ~= nil or
        cachedFactionInfo.paragonReputation ~= nil) then
      local paragonRepChange = getCacheDifference('paragonReputation');

      paragonLevelGained = (getCacheDifference('paragonLevel') > 0);
      repChange = repChange + paragonRepChange;
    end

    addon:yell('REPUTATION_CHANGED', faction, repChange, paragonLevelGained);
  end

  reputationCache = repInfo;
end

addon:on('PLAYER_LOGIN', function ()
  reputationCache = getRepInfo();
end);

addon:on('CHAT_MSG_COMBAT_FACTION_CHANGE', checkReputationChanges);
