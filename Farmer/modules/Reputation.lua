local addonName, addon = ...;

local MESSAGE_COLORS = {0, 0.35, 1};
local reputationCache;
local updateFlag = false;
local expandCount = 0;

local function getRepInfo ()
  local info = {};
  local numFactions = GetNumFactions();
  local expandedIndices = {};
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
      expandedIndices[#expandedIndices + 1] = i;
      --[[ expandCount has to be increased before collapsing, because
           UPDATE_FACTION are fired and handled immediately --]]
      expandCount = expandCount + 1;
      ExpandFactionHeader(i);
      numFactions = GetNumFactions();
    end

    if (hasRep or not isHeader) then
      local data = {};

      data.reputation = reputation;

      if (C_Reputation.IsFactionParagon(faction)) then
        local paragonInfo = {C_Reputation.GetFactionParagonInfo(faction)};

        data.paragonReputation = paragonInfo[1];
        data.paragonLevel = floor(paragonInfo[1] / paragonInfo[2]);
      end

      info[faction] = data;
    end

    i = i + 1;
  end

  --[[ the headers have to be collapse from bottom to top, because collapsing
       top ones first would change the index of the lower ones  --]]
  for i = #expandedIndices, 1, -1 do
    --[[ expandCount has to be increased before collapsing, because
         UPDATE_FACTION are fired and handled immediately --]]
    expandCount = expandCount + 1;
    CollapseFactionHeader(expandedIndices[i]);
  end

  return info;
end

local function checkReputationChanges ()
  local repInfo = getRepInfo();

  if (farmerOptions.reputation == false or
      addon.Print.checkHideOptions() == false) then
    reputationCache = repInfo;
    return;
  end

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

    if (repChange ~= 0) then
      if (repChange > 0) then
        repChange = '+' .. repChange;
      end

      if (paragonLevelGained == true) then
        repChange = repChange ..
            '|TInterface/TargetingFrame/UI-RaidTargetingIcon_1' ..
            addon.vars.iconOffset .. '|t';
      end

      --[[ could have stored faction name when generating faction info, but we
           can afford getting the name now for saving the memory ]]
      local message = GetFactionInfoByID(faction) .. ' ' .. repChange;

      addon.Print.printMessage(message, MESSAGE_COLORS);
    end
  end

  reputationCache = repInfo;
end

addon:on('PLAYER_LOGIN', function ()
  reputationCache = getRepInfo();
end);

addon:on('UPDATE_FACTION', function ()
  if (expandCount > 0) then
    expandCount = expandCount - 1;
    return;
  end

  if (reputationCache == nil) then
    return;
  end

  if (updateFlag == false) then
    updateFlag = true;

    C_Timer.After(0, function ()
      updateFlag = false;
      checkReputationChanges();
    end);
  end
end);
