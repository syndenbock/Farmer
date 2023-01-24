local addonName, addon = ...;

local min = _G.min;
local unpack = _G.unpack;
local tinsert = _G.tinsert;
local strfind = _G.strfind;
local MinimapSetDrawGroundTextures = _G.C_Minimap and _G.C_Minimap.SetDrawGroundTextures;
local MinimapGetDrawGroundTextures = _G.C_Minimap and _G.C_Minimap.GetDrawGroundTextures;
local CreateFrame = _G.CreateFrame;
local GetCVar = addon.import('polyfills/C_CVar').GetCVar;
local SetCVar = addon.import('polyfills/C_CVar').SetCVar;
local GetPlayerFacing = _G.GetPlayerFacing;
local InCombatLockdown = _G.InCombatLockdown;
local Minimap_UpdateRotationSetting = _G.Minimap_UpdateRotationSetting;
local Minimap = _G.Minimap;
local MinimapCluster = _G.MinimapCluster;
local WorldFrame = _G.WorldFrame;
local UIParent = _G.UIParent;

local L = addon.L;

local RADAR_CIRCLE_TEXTURE = 'Interface\\Addons\\' .. addonName ..
    '\\media\\radar_circle.tga';
local RADAR_DIRECTION_TEXTURE = 'Interface\\Addons\\' .. addonName ..
    '\\media\\radar_directions.tga';
local UPDATE_FREQUENCY_S = 0.01;
local FALLBACK_UPDATE_FREQUENCY_S = 1;

local MODE_ENUM = {
  OFF = 1,
  ON = 2,
  TOGGLING = 3,
};

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.FarmRadar;

local radarFrame;
local radarSize;
local directionTexture;
local currentMode = MODE_ENUM.OFF;
local updateStamp = 0;
local fallbackUpdateStamp = 0;
local minimapDefaults;
local trackedFrames;
local fallbackTrackedFrames;

local function findFrame (frame)
  if (type(frame) == 'string') then
    return _G[frame];
  else
    return frame;
  end
end

local function setFrameShown (frame, shown)
  if (frame.IsProtected and frame:IsProtected() and InCombatLockdown()) then
    addon.printAddonMessage('Could not hide or show a protected frame, please toggle farm mode after the fight.');
    return;
  end

  frame:SetShown(shown);
end

local function setFrameMouseEnabled (frame, enabled)
  if (frame.IsProtected and frame:IsProtected() and InCombatLockdown()) then
    return;
  end

  if (frame.EnableMouse) then
    frame:EnableMouse(enabled);
  end
end

local function setMinimapRotation (value)
  SetCVar('rotateMinimap', value, 'ROTATE_MINIMAP');

  -- Unavailable on Retail
  if (Minimap_UpdateRotationSetting) then
    Minimap_UpdateRotationSetting();
  end
end

local function moveFrameToMinimapClusterIfProtected (frame)
  --[[ We know your frames are very important ElvUI ]]
  if (frame.IsProtected and frame:IsProtected()) then
    frame:SetParent(MinimapCluster);
  end
end

local function fixMinimapTaint ()
  if (InCombatLockdown()) then return false end

  for _, child in ipairs({Minimap:GetChildren()}) do
    moveFrameToMinimapClusterIfProtected(child);
  end

  return true;
end

local function isMinimapTainted ()
  if (Minimap:IsProtected() and not fixMinimapTaint()) then
    addon.printAddonMessage('Some addon tainted the minimap, please toggle outside of combat');
    return true;
  end

  return false;
end

local function hideFrame (frame)
  frame = findFrame(frame);

  if (not frame or not frame.IsShown) then
    return;
  end

  trackedFrames[frame].hidden = true;
  setFrameShown(frame, false);
end

local function hideFrames (frames)
  for _, frame in ipairs(frames) do
    hideFrame(frame);
  end
end

local function storeFrame (frame)
  trackedFrames[frame] = {
    show = frame:IsShown(),
    mouseEnabled = frame.IsMouseEnabled and frame:IsMouseEnabled(),
  };
end

local function storeFrames (frames)
  for _, frame in ipairs(frames) do
    storeFrame(frame);
  end
end

local function storeMinimapChildren ()
  storeFrames({Minimap:GetChildren()});
  storeFrames({Minimap:GetRegions()});
end

local function restoreFrame (frame)
  local info = trackedFrames[frame];

  setFrameShown(frame, info.show);
  setFrameMouseEnabled(frame, info.mouseEnabled);
end

local function restoreAllFrames ()
  for frame in pairs(trackedFrames) do
    restoreFrame(frame);
  end
end

local function isGatherMatePin (name)
  return (strfind(name, '^GatherMatePin') == 1);
end

local function isGatherLitePin (name)
  return (strfind(name, '^GatherLite') == 1);
end

local function isHandyNotesPin (name)
  return (strfind(name, '^HandyNotesPin') == 1);
end

local function isQuestiePin (name)
  return (strfind(name, '^QuestieFrame') == 1);
end

local function shouldMinimapChildBeHidden (frame)
  local name = frame.GetName and frame:GetName();

  if (name) then
    if (isGatherMatePin(name) or isGatherLitePin(name) or
        isHandyNotesPin(name) or isQuestiePin(name)) then
      return false;
    end
  end

  return true;
end

local function getMinimapChildrenToHide ()
  local list = {};

  for _, child in ipairs({Minimap:GetChildren()}) do
    if (shouldMinimapChildBeHidden(child)) then
      tinsert(list, child);
    end
  end

  return list;
end

local function hideMinimapChildren ()
  local children = getMinimapChildrenToHide();

  hideFrames(children);
  hideFrames({Minimap:GetRegions()});
end

local function getMinimapValues ()
  return {
    parent = Minimap:GetParent(),
    anchor = {Minimap:GetPoint()},
    rotation = GetCVar('rotateMinimap'),
    alpha = Minimap:GetAlpha(),
    height = Minimap:GetHeight(),
    width = Minimap:GetWidth(),
    mouse = Minimap:IsMouseEnabled(),
    mouseWheel = Minimap:IsMouseWheelEnabled(),
    mouseMotion = Minimap:IsMouseMotionEnabled(),
    zoom = Minimap:GetZoom(),
    scale = Minimap:GetScale(),
    ignoreParentScale = Minimap:IsIgnoringParentScale(),
    clusterAlpha = MinimapCluster:GetAlpha(),
    drawGround = MinimapGetDrawGroundTextures and MinimapGetDrawGroundTextures(),
  };
end

local function createRadarTexture (frame, texturePath)
  local color = {0, 1, 0, 0.5};
  local texture = frame:CreateTexture(nil, 'OVERLAY');

  texture:SetTexture(texturePath);
  texture:SetVertexColor(unpack(color));
  texture:SetAllPoints(frame);

  return texture;
end

local function createRadarFrame ()
  local scale = 0.432;
  local radar = CreateFrame('Frame', 'FarmerRadarFrame', UIParent);

  radarSize = min(WorldFrame:GetHeight(), WorldFrame:GetWidth());
  radar:SetSize(radarSize * scale, radarSize * scale);
  radar:SetFrameStrata('MEDIUM');
  radar:SetPoint('CENTER', Minimap, 'CENTER', 0, 0);
  radar:SetIgnoreParentScale(true);
  radar:Hide();

  return radar;
end

local function initRadar ()
  if (radarFrame) then return end

  radarFrame = createRadarFrame();
  createRadarTexture(radarFrame, RADAR_CIRCLE_TEXTURE);
  directionTexture = createRadarTexture(radarFrame, RADAR_DIRECTION_TEXTURE);
end

local function setMinimapSize ()
  if (options.shrinkMinimap == true) then
    Minimap:SetSize(radarFrame:GetWidth(), radarFrame:GetHeight());
  else
    Minimap:SetSize(radarSize, radarSize);
  end
end

local function checkDefaultTooltips ()
  if (options.enableDefaultNodeTooltips == true) then
    Minimap:SetMouseMotionEnabled(true);
  end
end

local function checkAddonTooltips ()
  if (options.enableAddonNodeTooltips ~= false) then return end

  for _, child in ipairs({Minimap:GetChildren()}) do
    setFrameMouseEnabled(child, false);
  end
end

local function applyMinimapOptions ()
  setMinimapSize();
  checkDefaultTooltips();
  checkAddonTooltips();
end

local function updateRadar ()
  local rotation = GetPlayerFacing();

  --[[ After using a transport or in instances GetPlayerFacing returns nil ]]
  if (rotation) then
    directionTexture:Show();
    directionTexture:SetRotation(-rotation);
  else
    directionTexture:Hide();
  end
end

local function onUpdateHandler (_, elapsed)
  updateStamp = updateStamp + elapsed;

  if (updateStamp >= UPDATE_FREQUENCY_S) then
    updateRadar();
    updateStamp = 0;
  end
end

local function makeFramesIgnoreParentAlpha (...)
  for x = 1, select('#', ...), 1 do
    local child = select(x, ...);

    if (not fallbackTrackedFrames[child]) then
      fallbackTrackedFrames[child] = child:IsIgnoringParentAlpha();
      child:SetIgnoreParentAlpha(true);
    end
  end
end

local function makeMinimapChildrenIgnoreParentAlpha ()
  makeFramesIgnoreParentAlpha(Minimap:GetChildren());
  makeFramesIgnoreParentAlpha(Minimap:GetRegions());
end

local function unmakeMinimapChildrenIgnoreParentAlpha ()
  for child, ignore in pairs(fallbackTrackedFrames) do
    child:SetIgnoreParentAlpha(ignore);
  end
end

local function fallbackUpdateHandler (_, elapsed)
  onUpdateHandler(_, elapsed);

  fallbackUpdateStamp = fallbackUpdateStamp + elapsed;

  if (fallbackUpdateStamp >= FALLBACK_UPDATE_FREQUENCY_S) then
    makeMinimapChildrenIgnoreParentAlpha();
    fallbackUpdateStamp = 0;
  end
end

local function enableFarmMode ()
  initRadar();

  currentMode = MODE_ENUM.TOGGLING;

  minimapDefaults = getMinimapValues();

  --[[ MinimapCluster can get protected, so it can only be hidden with
       SetAlpha ]]
  MinimapCluster:SetAlpha(0);
  Minimap:SetParent(radarFrame);
  Minimap:ClearAllPoints();
  Minimap:SetPoint('CENTER', UIParent, 'CENTER', 0, 0);
  Minimap:SetScale(1);
  Minimap:SetIgnoreParentScale(false);
  Minimap:SetIgnoreParentAlpha(true);
  Minimap:EnableMouse(false);
  Minimap:EnableMouseWheel(false);
  Minimap:SetZoom(0);

  trackedFrames = {};
  storeMinimapChildren();
  hideMinimapChildren();
  applyMinimapOptions();
  setMinimapRotation(1);

  updateStamp = 0;
  updateRadar();

  if (MinimapSetDrawGroundTextures) then
    MinimapSetDrawGroundTextures(false);
    radarFrame:SetScript('OnUpdate', onUpdateHandler);
  else
    fallbackTrackedFrames = {};
    Minimap:SetAlpha(0);
    makeMinimapChildrenIgnoreParentAlpha();
    radarFrame:SetScript('OnUpdate', fallbackUpdateHandler);
  end

  radarFrame:Show();

  currentMode = MODE_ENUM.ON;
end

local function hideMinimapBackdropIfNeeded ()
  if (not Minimap.backdrop or not Minimap.backdrop.GetRegions) then return end

  Minimap.backdrop:SetFrameStrata('BACKGROUND');
  Minimap.backdrop:SetFrameLevel(0);
end

local function disableFarmMode ()
  currentMode = MODE_ENUM.TOGGLING;

  MinimapCluster:SetAlpha(minimapDefaults.clusterAlpha);
  Minimap:SetParent(minimapDefaults.parent);
  Minimap:ClearAllPoints();
  Minimap:SetPoint(unpack(minimapDefaults.anchor));
  Minimap:SetSize(minimapDefaults.width, minimapDefaults.height);
  Minimap:SetScale(minimapDefaults.scale);
  Minimap:SetIgnoreParentScale(minimapDefaults.ignoreParentScale);
  Minimap:EnableMouse(minimapDefaults.mouse);
  Minimap:EnableMouseWheel(minimapDefaults.mouseWheel);
  Minimap:SetMouseMotionEnabled(minimapDefaults.mouseMotion);
  Minimap:SetZoom(minimapDefaults.zoom);

  if (MinimapSetDrawGroundTextures) then
    MinimapSetDrawGroundTextures(minimapDefaults.drawGround);
  else
    Minimap:SetAlpha(minimapDefaults.alpha);
    unmakeMinimapChildrenIgnoreParentAlpha();
    fallbackTrackedFrames = nil;
  end

  radarFrame:SetScript('OnUpdate', nil);
  radarFrame:Hide();

  restoreAllFrames();
  trackedFrames = nil;
  setMinimapRotation(minimapDefaults.rotation);

  currentMode = MODE_ENUM.OFF;

  hideMinimapBackdropIfNeeded();
end

local function toggleFarmMode ()
  if (isMinimapTainted()) then return end

  local switch = {
    [MODE_ENUM.OFF] = enableFarmMode,
    [MODE_ENUM.ON] = disableFarmMode,
    [MODE_ENUM.TOGGLING] = function () end,
  };

  switch[currentMode]();
end

local function hideMinimapBackGroundIfInFarmMode ()
  if (currentMode == MODE_ENUM.ON and MinimapSetDrawGroundTextures) then
    MinimapSetDrawGroundTextures(false);
  end
end

local function restoreMinimapRotation ()
  if (currentMode ~= MODE_ENUM.ON) then return end

  setMinimapRotation(minimapDefaults.rotation);
end

addon.onOnce('PLAYER_LOGIN', fixMinimapTaint);
-- The game seems to re-enable the minimap background every time you teleport,
-- so it has to be hidden again
addon.on('PLAYER_ENTERING_WORLD', hideMinimapBackGroundIfInFarmMode);
addon.on('PLAYER_LOGOUT', restoreMinimapRotation);

addon.slash('radar', toggleFarmMode);
addon.exposeBinding('TOGGLERADAR', L['Toggle farming radar'], toggleFarmMode);
