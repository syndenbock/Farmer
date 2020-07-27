local _, addon = ...;

local GetBestMapForUnit = _G.C_Map.GetBestMapForUnit;
local GetVignettes = _G.C_VignetteInfo.GetVignettes;
local GetVignetteInfo = _G.C_VignetteInfo.GetVignetteInfo;
local GetVignettePosition = _G.C_VignetteInfo.GetVignettePosition;

local ImmutableMap = addon.Factory.ImmutableMap;

local UNIT_PLAYER = 'player';

local vignetteCache = {};
local currentMapId;

local function getCurrentMap ()
  return GetBestMapForUnit(UNIT_PLAYER);
end

local function yellVignette (info, coords)
  addon.yell('NEW_VIGNETTE',ImmutableMap(info), ImmutableMap(coords));
end

local function readVignette (guid)
  if (guid == nil or currentMapId == nil) then return end

  local info = GetVignetteInfo(guid);

  if (info == nil) then return end

  local vignetteId = info.vignetteID;

  if (vignetteCache[vignetteId] == guid) then return end

  local coords = GetVignettePosition(guid, currentMapId);

  if (coords == nil) then return end

  vignetteCache[vignetteId] = guid;

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
  vignetteCache = {};
end

addon.on({'PLAYER_LOGIN', 'ZONE_CHANGED_NEW_AREA'}, function ()
  clearVignetteCache();
  currentMapId = getCurrentMap();
  scanVignettes();
end);

addon.on('VIGNETTE_MINIMAP_UPDATED', function (guid)
  readVignette(guid);
end);
