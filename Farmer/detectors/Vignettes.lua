local _, addon = ...;

if (_G.C_VignetteInfo == nil) then
  addon.registerUnavailableDetector('vignettes');
  return;
end

local wipe = _G.wipe;

local GetBestMapForUnit = _G.C_Map.GetBestMapForUnit;
local GetVignettes = _G.C_VignetteInfo.GetVignettes;
local GetVignetteInfo = _G.C_VignetteInfo.GetVignetteInfo;
local GetVignettePosition = _G.C_VignetteInfo.GetVignettePosition;

local ImmutableMap = addon.import('core/classes/Maps').ImmutableMap;
local Events = addon.import('core/logic/Events');
local Yell = addon.import('core/logic/Yell');

local UNIT_PLAYER = 'player';

local vignetteCache = {};
local currentMapId;

addon.registerAvailableDetector('vignettes');

local function getCurrentMap ()
  return GetBestMapForUnit(UNIT_PLAYER);
end

local function yellVignette (info, coords)
  Yell.yell('NEW_VIGNETTE', ImmutableMap(info), coords);
end

-- first parameter is unused to be able to use it as an event listener
local function readVignette (_, vignetteGUID)
  if (currentMapId == nil) then return end

  local info = GetVignetteInfo(vignetteGUID);
  local coords = GetVignettePosition(vignetteGUID, currentMapId);

  if (not info or not coords) then return end

  local objectGUID = info.objectGUID;
  local onMinimap = info.onMinimap;

  -- If the vignette was already detected on the minimap it makes the second
  -- check redundant
  if (vignetteCache[objectGUID] == true or
      vignetteCache[objectGUID] == onMinimap) then
    return;
  end

  yellVignette(info, {
    x = coords.x * 100,
    y = coords.y * 100,
  });

  vignetteCache[objectGUID] = onMinimap;
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

Events.onOnce('PLAYER_LOGIN', initZone);
Events.on('ZONE_CHANGED_NEW_AREA', initZone);

Events.on('VIGNETTES_UPDATED', scanVignettes);
Events.on('VIGNETTE_MINIMAP_UPDATED', readVignette);
