local _, addon = ...;

if (addon.isClassic()) then return end

local GetBestMapForUnit = _G.C_Map.GetBestMapForUnit;
local GetVignettes = _G.C_VignetteInfo.GetVignettes;
local GetVignetteInfo = _G.C_VignetteInfo.GetVignetteInfo;
local GetVignettePosition = _G.C_VignetteInfo.GetVignettePosition;

local ImmutableMap = addon.Factory.ImmutableMap;
local Set = addon.Class.Set;

local UNIT_PLAYER = 'player';

local vignetteCache = Set:new();
local currentMapId;

local function getCurrentMap ()
  return GetBestMapForUnit(UNIT_PLAYER);
end

local function yellVignette (info, coords)
  addon.yell('NEW_VIGNETTE', ImmutableMap(info), ImmutableMap(coords));
end

local function readVignette (guid)
  if (vignetteCache:has(guid)) then return end

  local info = guid and currentMapId and GetVignetteInfo(guid);

  if (not info) then return end

  local coords = GetVignettePosition(guid, currentMapId);

  if (not coords) then return end

  vignetteCache:addItem(guid);
  yellVignette(info, {
    x = coords.x * 100,
    y = coords.y * 100,
  });
end

local function scanVignettes ()
  local list = GetVignettes();

  for x = 1, #list, 1 do
    readVignette(list[x]);
  end
end

local function clearVignetteCache ()
  vignetteCache:clear();
end

addon.on('PLAYER_LOGIN', function ()
  currentMapId = getCurrentMap();
end);

addon.on('ZONE_CHANGED_NEW_AREA', function ()
  currentMapId = getCurrentMap();
  clearVignetteCache();
  scanVignettes();
end);

addon.on('VIGNETTES_UPDATED', scanVignettes);
addon.on('VIGNETTE_MINIMAP_UPDATED', readVignette);
