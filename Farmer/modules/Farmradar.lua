local addonName, addon = ...;

local min = _G.min;
local strfind = _G.strfind;
local HasNewMail = _G.HasNewMail;
local GetPlayerFacing = _G.GetPlayerFacing;
local InCombatLockdown = _G.InCombatLockdown;
local Minimap_UpdateRotationSetting = _G.Minimap_UpdateRotationSetting;
local Minimap = _G.Minimap;
local MinimapCluster = _G.MinimapCluster;
local WorldFrame = _G.WorldFrame;
local UIParent = _G.UIParent;

local L = addon.L;
local Factory = addon.Factory;

local RADAR_CIRCLE_TEXTURE = 'Interface\\Addons\\' .. addonName .. '\\media\\radar_circle.tga';
local RADAR_DIRECTION_TEXTURE = 'Interface\\Addons\\' .. addonName .. '\\media\\radar_directions.tga';
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

local radar;
local directionTexture;
local currentMode = MODE_ENUM.OFF;
local updateStamp = 0;
local minimapDefaults;
local hookedFrames = Factory.WeakKeyMap();
local trackedFrames;
local minimapHooked = false;

local function addElementsToTable (fillTable, elements)
  for x = 1, #elements, 1 do
    table.insert(fillTable, elements[x]);
  end
end

local function setFrameShown (frame, shown)
  if (frame.IsProtected and frame:IsProtected() and InCombatLockdown()) then
    print(addonName, 'could not hide or show a protected frame, please toggle farm mode after the fight.');
    return;
  end

  frame:SetShown(shown);
end

local function setFrameMouseEnabled (frame, enabled)
  if (frame.IsProtected and frame:IsProtected() and InCombatLockdown()) then
    return;
  end

  if (not frame.EnableMouse) then
    return;
  end

  frame:EnableMouse(enabled);
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

local function fixMinimapTaint ()
  if (InCombatLockdown()) then return false end

  local children = {Minimap:GetChildren()};

  for x = 1, #children, 1 do
    local child = children[x];

    --[[ We know your frames are very important ElvUI ]]
    if (child.IsProtected and child:IsProtected()) then
      child:SetParent(MinimapCluster);
    end
  end

  return true;
end

local function isMinimapTainted ()
  if (Minimap:IsProtected() and not fixMinimapTaint()) then
    print(addonName .. ': some addon tainted the minimap, please toggle outside of combat');

    return true;
  end

  return false;
end

local function hookFrameToggle (frame)
  --[[ Some frames only exist in classic or retail ]]
  if (not frame) then return end

  --[[ Frame was already hooked ]]
  if (hookedFrames[frame]) then return end

  hookedFrames[frame] = true;

  hooksecurefunc(frame, 'Show', function (self)
    if (currentMode ~= MODE_ENUM.ON) then return end

    setFrameShown(self, false);
    trackedFrames[self] = true;
  end);

  hooksecurefunc(frame, 'Hide', function (self)
    if (currentMode ~= MODE_ENUM.ON) then return end

    trackedFrames[self] = false;
  end);
end

local function createRadarTexture (texturePath)
  local color = {0, 1, 0, 0.5};
  local texture = radar:CreateTexture(nil, 'OVERLAY');

  texture:SetTexture(texturePath);
  texture:SetVertexColor(unpack(color));
  texture:SetAllPoints(radar);

  return texture;
end

local function init ()
  fixMinimapTaint();

  radar = CreateFrame('Frame', 'FarmerRadarFrame', UIParent);
  radar:SetFrameStrata('HIGH');
  radar:SetPoint('CENTER', UIParent, 'CENTER', 0, 0);
  radar:Hide();
  addon:setTrueScale(radar, 1);

  createRadarTexture(RADAR_CIRCLE_TEXTURE);
  directionTexture = createRadarTexture(RADAR_DIRECTION_TEXTURE);
end

local function hideChildren (children, hook)
  for x = 1, #children, 1 do
    local child = children[x];

    if (type(child) == 'string') then
      child = _G[child];
    end

    if (child and child.IsShown and not trackedFrames[child]) then
      trackedFrames[child] = child:IsShown();
      setFrameShown(child, false);
      setFrameMouseEnabled(child, false);

      if (hook == true) then
        hookFrameToggle(child);
      end
    end
  end
end

local function isMinimapButton (frame)
  local name = frame and frame.GetName and frame:GetName();

  if (not name) then return false end

  local baseString = 'LibDBIcon';

  return (strfind(name, baseString) == 1);
end

local function getMinimapButtons (parent)
  local children = {parent:GetChildren()};
  local iconList = {};

  for x = 1, #children, 1 do
    child = children[x];

    if (isMinimapButton(child)) then
      table.insert(iconList, child);
    end

    addElementsToTable(iconList, getMinimapButtons(child));
  end

  return iconList;
end

local function SetIgnoreParentAlpha (children, ignore)
  for x = 1, #children, 1 do
    local child = children[x];

    if (type(child) == 'string') then
      child = _G[child];
    end

    if (child) then
      setFrameMouseEnabled(child, not ignore);
      child:SetIgnoreParentAlpha(ignore);
    end
  end
end

local function hideMinimapChildren ()
  trackedFrames = {};

  --[[ MinimapCluster can get protected, so it can only be hidden with
       SetAlpha ]]
  MinimapCluster:SetAlpha(0);
  hideChildren(DEFAULT_CHILD_LIST, true);
  hideChildren(getMinimapButtons(Minimap), true);
  hideChildren({Minimap.backdrop}, false);
  hideChildren({Minimap:GetRegions()}, false);

  SetIgnoreParentAlpha({Minimap:GetChildren()}, true)
  SetIgnoreParentAlpha({Minimap:GetRegions()}, true)
end

local function updateMinimapChildren ()
  --[[ Execute on the next frame so other addons can update their icons ]]
  addon:executeOnNextFrame(function ()
    SetIgnoreParentAlpha({Minimap:GetChildren()}, true);
    SetIgnoreParentAlpha({Minimap:GetRegions()}, true);
  end);
end

local function showHiddenFrames ()
  MinimapCluster:SetAlpha(1);

  for frame, visibility in pairs(trackedFrames) do
    setFrameShown(frame, visibility);
  end

  SetIgnoreParentAlpha({Minimap:GetChildren()}, false)
  SetIgnoreParentAlpha({Minimap:GetRegions()}, false)

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

local function enableFarmMode ()
  local size = min(WorldFrame:GetHeight(), WorldFrame:GetWidth());
  local scale = 0.432;

  currentMode = MODE_ENUM.TOGGLING;

  minimapDefaults = {
    parent = Minimap:GetParent(),
    anchor = {Minimap:GetPoint()},
    rotation = GetCVar('rotateMinimap'),
    height = Minimap:GetHeight(),
    width = Minimap:GetWidth(),
    mouse = Minimap:IsMouseEnabled(),
    mouseWheel = Minimap:IsMouseWheelEnabled(),
    zoom = Minimap:GetZoom(),
    scale = Minimap:GetScale(),
  };

  Minimap:ClearAllPoints();
  Minimap:SetPoint('CENTER', radar, 'CENTER', 0, 0);
  Minimap:SetParent(radar);
  Minimap:SetSize(size, size);
  Minimap:SetScale(1);
  Minimap:EnableMouse(false);
  Minimap:EnableMouseWheel(false);
  Minimap:SetZoom(0);
  Minimap:SetAlpha(0);
  hookMinimapAlpha();

  radar:SetSize(size * scale, size * scale);
  radar:Show();
  radar:SetScript('OnUpdate', updateRadar);
  updateStamp = UPDATE_FREQUENCY_S;

  hideMinimapChildren();

  SetCVar('rotateMinimap', 1, 'ROTATE_MINIMAP');
  Minimap_UpdateRotationSetting();

  addon:on('ZONE_CHANGED', updateMinimapChildren);

  currentMode = MODE_ENUM.ON;
end

local function disableFarmMode ()
  currentMode = MODE_ENUM.TOGGLING;

  Minimap:ClearAllPoints();
  Minimap:SetPoint(unpack(minimapDefaults.anchor));
  Minimap:SetParent(minimapDefaults.parent);
  Minimap:SetSize(minimapDefaults.width, minimapDefaults.height);
  Minimap:SetScale(minimapDefaults.scale);
  Minimap:EnableMouse(minimapDefaults.mouse);
  Minimap:EnableMouseWheel(minimapDefaults.mouseWheel);
  Minimap:SetZoom(minimapDefaults.zoom);

  radar:Hide();
  radar:SetScript('OnUpdate', nil);

  showHiddenFrames();
  Minimap:SetAlpha(1);

  SetCVar('rotateMinimap', minimapDefaults.rotation, 'ROTATE_MINIMAP');
  Minimap_UpdateRotationSetting();

  addon:off('ZONE_CHANGED', updateMinimapChildren);

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

  SetCVar('rotateMinimap', minimapDefaults.rotation, 'ROTATE_MINIMAP');
  Minimap_UpdateRotationSetting();
end

addon:on('PLAYER_LOGIN', init);
addon:on('PLAYER_LOGOUT', restoreMinimapRotation);

addon:slash('radar', toggleFarmMode);
addon:exposeBinding('TOGGLERADAR', L['Toggle radar'], toggleFarmMode);
