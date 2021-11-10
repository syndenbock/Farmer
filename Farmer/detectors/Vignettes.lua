local _, addon = ...;

if (_G.C_VignetteInfo == nil) then
  addon.registerUnavailableDetector('vignettes');
  return;
end

addon.registerAvailableDetector('vignettes');

local wipe = _G.wipe;

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

local function yellVignette (info, coords, onMinimap)
  addon.yell('NEW_VIGNETTE', info, coords, onMinimap);
end

-- first parameter is unused to be able to use it as an event listener
local function readVignette (_, guid)
  if (currentMapId == nil) then return end

  local state = vignetteCache[guid];

  -- vignette was already triggered both as not on minimap and as on minimap
  if (state == true) then return end

  local info = GetVignetteInfo(guid);

  if (not info) then return end

  local coords = GetVignettePosition(guid, currentMapId);

  if (not coords) then return end

  local onMinimap = info.onMinimap;

  -- info object could be used for both on minimap and not on minimap so
  -- onMinimap flag will be passed separately
  info.onMinimap = nil;
  info = ImmutableMap(info);

  coords = {
    x = coords.x * 100,
    y = coords.y * 100,
  };

  if (state == nil) then
    yellVignette(info, coords, false);
  end

  if (onMinimap == true) then
    yellVignette(info, coords, true);
  end

  vignetteCache[guid] = onMinimap;
end

local function scanVignettes ()
  for _, guid in ipairs(GetVignettes()) do
    readVignette(nil, guid);
  end
end

local function initZone ()
  currentMapId = getCurrentMap();
  wipe(vignetteCache);
  scanVignettes();
end

addon.onOnce('PLAYER_LOGIN', initZone);
addon.on('ZONE_CHANGED_NEW_AREA', initZone);

addon.on('VIGNETTES_UPDATED', scanVignettes);
addon.on('VIGNETTE_MINIMAP_UPDATED', readVignette);
