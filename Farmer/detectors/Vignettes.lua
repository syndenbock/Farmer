local _, addon = ...;

local pow = math.pow;
local floor = _G.floor;
local GetBestMapForUnit = _G.C_Map.GetBestMapForUnit;
local GetVignettes = _G.C_VignetteInfo.GetVignettes;
local GetVignetteInfo = _G.C_VignetteInfo.GetVignetteInfo;
local GetVignettePosition = _G.C_VignetteInfo.GetVignettePosition;

local UNIT_PLAYER = 'player';

local vignetteCache = {};
local currentMapId;

local function truncate (number, digits)
  local factor = pow(10, digits);

  number = number * factor;
  number = floor(number);
  number = number / factor;

  return number;
end

local function getCurrentmap ()
  return GetBestMapForUnit(UNIT_PLAYER);
end

local function readVignette (guid)
  if (guid == nil or currentMapId == nil) then return end

  local info = GetVignetteInfo(guid);

  if (info == nil) then return end

  local vignetteId = info.vignetteID;

  if (vignetteCache[vignetteId] == guid) then return end

  local coords = GetVignettePosition(guid, currentMapId);

  if (coords == nil) then return end

  local x = truncate(coords.x * 100, 1);
  local y = truncate(coords.y * 100, 1);

  vignetteCache[vignetteId] = guid;

  print(info.name, x, '/', y);
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

addon.on({'ZONE_CHANGED_NEW_AREA', 'PLAYER_LOGIN'}, function ()
  clearVignetteCache();
  currentMapId = getCurrentmap();
  scanVignettes();
end);

addon.on('VIGNETTE_MINIMAP_UPDATED', function (guid)
  readVignette(guid);
end);
