local addonName, addon = ...;

local min = _G.min;
local unpack = _G.unpack;
local tinsert = _G.tinsert;
local strfind = _G.strfind;
local hooksecurefunc = _G.hooksecurefunc;
local CreateFrame = _G.CreateFrame;
local GetCVar = _G.GetCVar;
local SetCVar = _G.SetCVar;
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
local minimapDefaults;
local hookedFrames = addon.Class.Set:new();
local trackedFrames;
local minimapHooked = false;

local function findFrame (frame)
  if (type(frame) == 'string') then
    return _G[frame];
  else
    return frame;
  end
end

local function setFrameShown (frame, shown)
  if (frame.IsProtected and frame:IsProtected() and InCombatLockdown()) then
    print(addonName, 'could not hide or show a protected frame, ' ..
        'please toggle farm mode after the fight.');
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
  Minimap_UpdateRotationSetting();
end

local function hookMinimapAlpha ()
  if (minimapHooked == true) then return end

  local oldSetAlpha = Minimap.SetAlpha;

  Minimap.SetAlpha = function (self, value)
    if (currentMode ~= MODE_ENUM.ON) then
      oldSetAlpha(self, value);
    end
  end;

  minimapHooked = true;
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
    print(addonName ..
        ': some addon tainted the minimap, please toggle outside of combat');

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

local function shouldHookBeApplied (frame)
  return (currentMode == MODE_ENUM.ON and
          trackedFrames[frame] and
          trackedFrames[frame].hidden);
end

local function hookFrameShow (frame)
  hooksecurefunc(frame, 'Show', function (self)
    if (not shouldHookBeApplied(self)) then return end

    setFrameShown(self, false);
    trackedFrames[self].show = true;
  end);
end

local function hookFrameHide (frame)
  hooksecurefunc(frame, 'Hide', function (self)
    if (not shouldHookBeApplied(self)) then return end

    trackedFrames[self].show = false;
  end);
end

local function hookFrameToggle (frame)
  --[[ Frame was already hooked ]]
  if (hookedFrames:has(frame)) then return end

  hookedFrames:addItem(frame);
  hookFrameShow(frame);
  hookFrameHide(frame);
end

local function hookFrames (frames)
  for _, frame in ipairs(frames) do
    hookFrameToggle(frame);
  end
end

local function isGatherMatePin (name)
  return (strfind(name, 'GatherMatePin') == 1);
end

local function isHandyNotesPin (name)
  return (strfind(name, 'HandyNotesPin') == 1);
end

local function checkPinOptions (name)
  if (options.showHandyNotesPins == true and isHandyNotesPin(name)) then
    return false;
  end

  if (options.showGatherMateNodes == true and isGatherMatePin(name)) then
    return false;
  end

  return true;
end

local function storeFrame (frame)
  trackedFrames[frame] = {
    show = frame:IsShown(),
    mouseEnabled = frame.IsMouseEnabled and frame:IsMouseEnabled(),
    ignoreAlpha = frame.IsIgnoringParentAlpha and frame:IsIgnoringParentAlpha(),
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
  frame:SetIgnoreParentAlpha(info.ignoreAlpha);
end

local function restoreAllFrames ()
  for frame in pairs(trackedFrames) do
    restoreFrame(frame);
  end
end

local function shouldMinimapChildBeHidden (frame)
  local name = frame.GetName and frame:GetName();

  if (not name) then
    return true;
  end

  return (checkPinOptions(name));
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

local function setFrameIgnoreParentAlpha (frame, ignore)
  frame = findFrame(frame);

  if (frame) then
    frame:SetIgnoreParentAlpha(ignore);
  end
end

local function setIgnoreParentAlpha (frames, ignore)
  for _, frame in ipairs(frames) do
    setFrameIgnoreParentAlpha(frame, ignore);
  end
end

local function hideMinimapChildren ()
  --[[ MinimapCluster can get protected, so it can only be hidden with
       SetAlpha ]]

  local children = getMinimapChildrenToHide();

  hideFrames(children);
  hideFrames({Minimap:GetRegions()});

  hookFrames(children);

  setIgnoreParentAlpha({Minimap:GetChildren()}, true);
  setIgnoreParentAlpha({Minimap:GetRegions()}, true);
end

local function getMinimapValues ()
  return {
    parent = Minimap:GetParent(),
    anchor = {Minimap:GetPoint()},
    rotation = GetCVar('rotateMinimap'),
    height = Minimap:GetHeight(),
    width = Minimap:GetWidth(),
    mouse = Minimap:IsMouseEnabled(),
    mouseWheel = Minimap:IsMouseWheelEnabled(),
    mouseMotion = Minimap:IsMouseMotionEnabled(),
    zoom = Minimap:GetZoom(),
    scale = Minimap:GetScale(),
    clusterAlpha = MinimapCluster:GetAlpha(),
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
  radar:SetPoint('CENTER', UIParent, 'CENTER', 0, 0);
  radar:Hide();
  addon.setTrueScale(radar, 1);

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

  local children = {Minimap:GetChildren()};

  for _, child in ipairs(children) do
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

local function enableFarmMode ()
  initRadar();

  currentMode = MODE_ENUM.TOGGLING;

  minimapDefaults = getMinimapValues();

  MinimapCluster:SetAlpha(0);
  Minimap:SetParent(radarFrame);
  Minimap:ClearAllPoints();
  Minimap:SetPoint('CENTER', radarFrame, 'CENTER', 0, 0);

  addon.setTrueScale(Minimap, 1);
  Minimap:EnableMouse(false);
  Minimap:EnableMouseWheel(false);
  Minimap:SetZoom(0);
  Minimap:SetAlpha(0);

  trackedFrames = {};
  storeMinimapChildren();
  hideMinimapChildren();
  applyMinimapOptions();
  setMinimapRotation(1);
  hookMinimapAlpha();

  updateStamp = 0;
  updateRadar();
  radarFrame:SetScript('OnUpdate', onUpdateHandler);
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
  Minimap:EnableMouse(minimapDefaults.mouse);
  Minimap:EnableMouseWheel(minimapDefaults.mouseWheel);
  Minimap:SetMouseMotionEnabled(minimapDefaults.mouseMotion);
  Minimap:SetAlpha(1);
  Minimap:SetZoom(minimapDefaults.zoom);

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

local function restoreMinimapRotation ()
  if (currentMode ~= MODE_ENUM.ON) then return end

  setMinimapRotation(minimapDefaults.rotation);
end

addon.onOnce('PLAYER_LOGIN', fixMinimapTaint);
addon.on('PLAYER_LOGOUT', restoreMinimapRotation);

addon.slash('radar', toggleFarmMode);
addon.exposeBinding('TOGGLERADAR', L['Toggle farming radar'], toggleFarmMode);
