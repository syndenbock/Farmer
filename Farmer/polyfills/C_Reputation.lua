local _, addon = ...;

local C_Reputation = _G.C_Reputation or {};

local function packFactionInfo (...)
  local info = {...};

  return {
    factionID = info[14],
    name = info[1],
    description = info[2],
    reaction = info[3],
    currentReactionThreshold = info[4],
    nextReactionThreshold = info[5],
    currentStanding = info[6],
    atWarWith = info[7],
    canToggleAtWar = info[8],
    isChild = info[13],
    isHeader = info[9],
    isHeaderWithRep = info[11],
    isCollapsed = info[10],
    isWatched = info[12],
    hasBonusRepGain = info[15],
    canSetInactive = info[16],
    -- isAccountWide
  };
end

local function GetFactionDataByIndex (...)
  return packFactionInfo(_G.GetFactionInfo(...));
end

local function GetFactionDataByID (...)
  return packFactionInfo(_G.GetFactionInfoByID(...));
end

addon.export('polyfills/C_Reputation', {
  GetNumFactions = C_Reputation.GetNumFactions or _G.GetNumFactions,
  GetFactionDataByIndex = C_Reputation.GetFactionDataByIndex or GetFactionDataByIndex,
  GetFactionDataByID = C_Reputation.GetFactionDataByID or GetFactionDataByID,
  ExpandFactionHeader = C_Reputation.ExpandFactionHeader or _G.ExpandFactionHeader,
  CollapseFactionHeader = C_Reputation.CollapseFactionHeader or _G.CollapseFactionHeader,
  GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo or nil,
  IsFactionParagon = C_Reputation.IsFactionParagon or function ()
    return false;
  end,
});
