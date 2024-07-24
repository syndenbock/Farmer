local _, addon = ...;

if (C_Reputation ~= nil) then
  addon.export('polyfills/C_Reputation', C_Reputation);
  return;
end

local GetFactionInfo = _G.GetFactionInfo;
local GetFactionInfoByID = _G.GetFactionInfoByID;

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
  return packFactionInfo(GetFactionInfo(...));
end

local function GetFactionDataById (...)
  return packFactionInfo(GetFactionInfoByID(...));
end

addon.export('polyfills/C_Reputation', C_Reputation or {
  GetNumFactions = _G.GetNumFactions,
  GetFactionDataByIndex = GetFactionDataByIndex,
  GetFactionDataById = GetFactionDataById,
  ExpandFactionHeader = _G.ExpandFactionHeader,
  CollapseFactionHeader = _G.CollapseFactionHeader,
  GetFactionParagonInfo = nil,
  IsFactionParagon = function ()
    return false;
  end,
});
