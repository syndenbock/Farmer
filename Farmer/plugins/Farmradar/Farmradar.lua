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
local Factory = addon.Factory;
local Set = Factory.Set;

local RADAR_CIRCLE_TEXTURE = 'Interface\\Addons\\' .. addonName ..
    '\\media\\radar_circle.tga';
local RADAR_DIRECTION_TEXTURE = 'Interface\\Addons\\' .. addonName ..
    '\\media\\radar_directions.tga';
local UPDATE_FREQUENCY_S = 0.01;

local DEFAULT_CHILD_LIST = {
  'GameTimeFrame',
  'MiniMapMailFrame',
  'MinimapBackdrop',
  'TimeManagerClockButton',
  'MiniMapTrackingFrame',
  'GarrisonLandingPageMinimapButton',
  'MiniMapInstanceDifficulty',
  'GuildInstanceDifficulty',
  'MiniMapChallengeMode',
  'QueueStatusMinimapButton',
  'MinimapZoneTextButton',
  'MinimapBorderTop',
};

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
local hookedFrames = Set:new();
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

  local children = {Minimap:GetChildren()};

  for x = 1, #children, 1 do
    moveFrameToMinimapClusterIfProtected(children[x]);
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

local function hookFrameShow (frame)
  hooksecurefunc(frame, 'Show', function (self)
    if (currentMode ~= MODE_ENUM.ON or trackedFrames[self] == nil) then return end

    setFrameShown(self, false);
    trackedFrames[self] = true;
  end);
end

local function hookFrameHide (frame)
  hooksecurefunc(frame, 'Hide', function (self)
    if (currentMode ~= MODE_ENUM.ON or trackedFrames[self] == nil) then return end

    trackedFrames[self] = false;
  end);
end

local function hookFrameToggle (frame)
  --[[ Some frames only exist in classic or retail ]]
  if (not frame) then return end

  --[[ Frame was already hooked ]]
  if (hookedFrames:has(frame)) then return end

  hookedFrames:addItem(frame);
  hookFrameShow(frame);
  hookFrameHide(frame);
end

local function hideFrame (frame, hook)
  frame = findFrame(frame);

  if (not frame or not frame.IsShown or trackedFrames[frame] ~= nil) then
    return;
  end

  trackedFrames[frame] = frame:IsShown();
  setFrameShown(frame, false);

  if (hook == true) then
    hookFrameToggle(frame);
  end
end

local function hideFrames (frames, hook)
  for x = 1, #frames, 1 do
    hideFrame(frames[x], hook);
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

local function shouldMinimapChildBeHidden (frame)
  local name = frame and frame.GetName and frame:GetName();

  if (not name) then return true end

  return (checkPinOptions(name));
end

local function getMinimapChildrenToHide ()
  local children = {Minimap:GetChildren()};
  local list = {};

  for x = 1, #children, 1 do
    local child = children[x];

    if (shouldMinimapChildBeHidden(child)) then
      tinsert(list, child);
    end
  end

  return list;
end

local function setFrameIgnoreParentAlpha (frame, ignore)
  frame = findFrame(frame);

  if (not frame) then return end

  frame:SetIgnoreParentAlpha(ignore);
end

local function setIgnoreParentAlpha (frames, ignore)
  for x = 1, #frames, 1 do
    setFrameIgnoreParentAlpha(frames[x], ignore);
  end
end

local function hideMinimapChildren ()
  trackedFrames = {};

  --[[ MinimapCluster can get protected, so it can only be hidden with
       SetAlpha ]]
  MinimapCluster:SetAlpha(0);
  hideFrames(DEFAULT_CHILD_LIST, true);
  hideFrames(getMinimapChildrenToHide(), true);
  hideFrames({Minimap.backdrop}, false);
  hideFrames({Minimap:GetRegions()}, false);

  setIgnoreParentAlpha({Minimap:GetChildren()}, true)
  setIgnoreParentAlpha({Minimap:GetRegions()}, true)
end

local function updateMinimapChildren ()
  --[[ Execute on the next frame so other addons can update their icons ]]
  addon.executeOnNextFrame(function ()
    setIgnoreParentAlpha({Minimap:GetChildren()}, true);
    setIgnoreParentAlpha({Minimap:GetRegions()}, true);
  end);
end

local function showHiddenFrames ()
  MinimapCluster:SetAlpha(1);

  for frame, visibility in pairs(trackedFrames) do
    setFrameShown(frame, visibility);
  end

  setIgnoreParentAlpha({Minimap:GetChildren()}, false)
  setIgnoreParentAlpha({Minimap:GetRegions()}, false)

  trackedFrames = nil;
end

local function updateRadar (_, elapsed)
  updateStamp = updateStamp + elapsed;

  if ((updateStamp) < UPDATE_FREQUENCY_S) then return end

  local rotation = GetPlayerFacing();

  --[[ After using a transport or in instances GetPlayerFacing returns nil ]]
  if (not rotation) then
    directionTexture:Hide();
    return;
  end

  directionTexture:Show();
  directionTexture:SetRotation(-rotation);
  updateStamp = 0;
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

local function applyMinimapOptions ()
  setMinimapSize();
  checkDefaultTooltips();
end

local function enableFarmMode ()
  initRadar();

  currentMode = MODE_ENUM.TOGGLING;

  minimapDefaults = getMinimapValues();

  Minimap:ClearAllPoints();
  Minimap:SetPoint('CENTER', radarFrame, 'CENTER', 0, 0);
  -- Minimap:SetParent(radarFrame);
  --[[ if an option is to be added to make the minimap area bigger than the
       radar, this is the place to set the size ]]

  addon.setTrueScale(Minimap, 1);
  Minimap:EnableMouse(false);
  Minimap:EnableMouseWheel(false);
  Minimap:SetZoom(0);
  Minimap:SetAlpha(0);

  applyMinimapOptions();
  hookMinimapAlpha();

  radarFrame:Show();
  radarFrame:SetScript('OnUpdate', updateRadar);
  updateStamp = UPDATE_FREQUENCY_S;

  hideMinimapChildren();
  setMinimapRotation(1);

  addon.on('ZONE_CHANGED', updateMinimapChildren);

  currentMode = MODE_ENUM.ON;
end

local function disableFarmMode ()
  currentMode = MODE_ENUM.TOGGLING;

  Minimap:ClearAllPoints();
  Minimap:SetPoint(unpack(minimapDefaults.anchor));
  -- Minimap:SetParent(minimapDefaults.parent);
  Minimap:SetSize(minimapDefaults.width, minimapDefaults.height);
  Minimap:SetScale(minimapDefaults.scale);
  Minimap:EnableMouse(minimapDefaults.mouse);
  Minimap:EnableMouseWheel(minimapDefaults.mouseWheel);
  Minimap:SetMouseMotionEnabled(minimapDefaults.mouseMotion);
  Minimap:SetAlpha(1);
  Minimap:SetZoom(minimapDefaults.zoom);

  radarFrame:Hide();
  radarFrame:SetScript('OnUpdate', nil);

  showHiddenFrames();

  setMinimapRotation(minimapDefaults.rotation);

  addon.off('ZONE_CHANGED', updateMinimapChildren);

  currentMode = MODE_ENUM.OFF;
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

addon.on('PLAYER_LOGIN', fixMinimapTaint);
addon.on('PLAYER_LOGOUT', restoreMinimapRotation);

addon.slash('radar', toggleFarmMode);
addon.exposeBinding('TOGGLERADAR', L['Toggle radar'], toggleFarmMode);
