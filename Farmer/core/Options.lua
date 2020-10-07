local addonName, addon = ...;

local unpack = _G.unpack;
local strupper = _G.strupper;
local GetItemIcon = _G.GetItemIcon;
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT;
-- for some reason they are not strings but numbers unlike MessageFrame modes
local SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP =
    _G.SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP or 1;
local SCROLLING_MESSAGE_FRAME_INSERT_MODE_BOTTOM =
    _G.SCROLLING_MESSAGE_FRAME_INSERT_MODE_BOTTOM or 2;

local L = addon.L;
local addonVars = addon.share('vars');

local ADDON_ICON_ID = 3334;
local ANCHOR_DEFAULT = {'BOTTOM', nil, 'CENTER', 0, 50};
local INSERTMODE_DEFAULT = SCROLLING_MESSAGE_FRAME_INSERT_MODE_BOTTOM;
local HORIZONTAL_ALIGN_DEFAULT = 'CENTER';

local Panel = addon.OptionClass.Panel;
local mainPanel = Panel:new(addonName);
local farmerFrame = addon.frame;

addon.mainPanel = mainPanel.panel;

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Core = {
      anchor = ANCHOR_DEFAULT,
      insertMode = INSERTMODE_DEFAULT,
      displayTime = 4,
      fontSize = 18,
      iconScale = 0.8,
      spacing = 0,
      outline = 'OUTLINE',
      hideAtMailbox = true,
      hideInArena = true,
      hideOnExpeditions = true,
      itemNames = true,
      horizontalAlign = HORIZONTAL_ALIGN_DEFAULT,
    },
  },
});

local options = saved.vars.farmerOptions.Core;

local function storePosition ()
  options.anchor = {farmerFrame:GetPoint()};
end

local function displayMovingIcon ()
  local icon = addon.getIcon(GetItemIcon(ADDON_ICON_ID));

  farmerFrame:Clear();
  farmerFrame:AddMessage(icon);
end

local function stopMovingFrame ()
  displayMovingIcon();

  farmerFrame:EnableMouse(false);
  farmerFrame:SetMovable(false);
  farmerFrame:SetFading(true);
  farmerFrame:StopMovingOrSizing();
  farmerFrame:SetScript('OnDragStart', nil);
  farmerFrame:SetScript('OnReceiveDrag', nil);
  storePosition();
end

local function frameOnDragStart (frame)
  if (frame:IsMovable() == true) then
    frame:StartMoving();
  end
end

local function moveFrame ()
  displayMovingIcon();

  farmerFrame:RegisterForDrag('LeftButton');
  farmerFrame:SetFading(false);
  farmerFrame:EnableMouse(true);
  farmerFrame:SetMovable(true);
  farmerFrame:SetScript('OnDragStart', frameOnDragStart);

  farmerFrame:SetScript('OnReceiveDrag', stopMovingFrame);
end

local function getProperInsertmode (mode)
  if (type(mode) ~= 'string') then
    return mode;
  end

  local aliasMap = {
    BOTTOM = SCROLLING_MESSAGE_FRAME_INSERT_MODE_BOTTOM,
    TOP = SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP,
  };

  mode = strupper(mode);

  return aliasMap[mode] or mode;
end

local function setInsertMode (mode)
  local currentMode = getProperInsertmode(farmerFrame:GetInsertMode());

  mode = getProperInsertmode(mode);

  if (mode == currentMode) then return end

  local anchor = {farmerFrame:GetPoint()};

  if (mode == SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP) then
    anchor[5] = anchor[5] - farmerFrame:GetHeight();
  elseif (mode == SCROLLING_MESSAGE_FRAME_INSERT_MODE_BOTTOM) then
    anchor[5] = anchor[5] + farmerFrame:GetHeight();
  end

  farmerFrame:SetPoint(unpack(anchor));
  storePosition();
  farmerFrame:SetInsertMode(mode);
end

local function setHorizontalAlignment (alignment)
  local currentAlignment = strupper(farmerFrame:GetJustifyH());

  alignment = strupper(alignment);

  if (currentAlignment == alignment) then return end

  local alignFactors = {
    LEFT = -1,
    CENTER = 0,
    RIGHT = 1,
  };
  local offset = farmerFrame:GetWidth() / 2;
  local anchor = {farmerFrame:GetPoint()};

  offset = (alignFactors[currentAlignment] - alignFactors[alignment]) * offset;
  anchor[4] = anchor[4] + offset;
  farmerFrame:SetPoint(unpack(anchor));
  storePosition();
  farmerFrame:SetJustifyH(alignment);
end

local function setFramePosition (position)
  farmerFrame:ClearAllPoints();
  farmerFrame:SetPoint(unpack(position));
end

local function setDefaultPosition ()
  setFramePosition(ANCHOR_DEFAULT);

  -- setting to the default insert mode first and then applying the actual
  -- insert mode will move the frame to the correct mode position
  farmerFrame:SetInsertMode(INSERTMODE_DEFAULT);
  setInsertMode(options.insertMode);

  -- setting the default horizontal alignment first and then applying the
  -- actual aligment to move the frame to the correct position
  farmerFrame:SetJustifyH(HORIZONTAL_ALIGN_DEFAULT);
  setHorizontalAlignment(options.horizontalAlign);

  displayMovingIcon();
end

local function setFontOptions (options)
  local scale = farmerFrame:GetEffectiveScale();
  local shadowOffset = options.fontSize / 10;
  local iconSize = options.fontSize * options.iconScale * scale;
  local iconOffset = -options.spacing * 1.5 * scale;

  --[[ we have to use the standard font because on screen messages are always
       localized --]]
  farmerFrame:SetFont(STANDARD_TEXT_FONT, options.fontSize, options.outline);
  farmerFrame:SetShadowColor(0, 0, 0);
  farmerFrame:SetShadowOffset(shadowOffset, -shadowOffset);
  farmerFrame:SetSpacing(options.spacing);
  addonVars.iconOffset = addon.stringJoin(
      {'', iconSize, iconSize, 0, iconOffset}, ':');
end

_G.hooksecurefunc(farmerFrame, 'SetScale', function ()
  setFontOptions(options);
end);

local function setVisibleTime (displayTime)
  farmerFrame:SetTimeVisible(displayTime - farmerFrame:GetFadeDuration());
end

local function applyOptions ()
  setInsertMode(options.insertMode);
  setFontOptions(options);
  setVisibleTime(options.displayTime);
  setHorizontalAlignment(options.horizontalAlign);
end

do
  local optionMap = {};

  optionMap.itemNames = mainPanel:addCheckBox(L['show names of all items']);
  optionMap.hideAtMailbox = mainPanel:addCheckBox(L['don\'t display at mailboxes']);

  if (not addon.isClassic()) then
    optionMap.hideInArena = mainPanel:addCheckBox(L['don\'t display in arena']);
    optionMap.hideOnExpeditions = mainPanel:addCheckBox(L['don\'t display on island expeditions']);
  end

  optionMap.fontSize = mainPanel:addSlider(8, 64, L['font size'], '8', '64', 0);
  optionMap.iconScale = mainPanel:addSlider(0.1, 3, L['icon scale'], '0.1', '3', 1);
  optionMap.displayTime = mainPanel:addSlider(1, 10, L['display time'], '1', '10', 0);
  optionMap.spacing = mainPanel:addSlider(0, 20, L['line spacing'], '0', '20', 0);

  optionMap.insertMode = mainPanel:addDropdown(L['grow direction'], {
    {
      text = L['up'],
      value = SCROLLING_MESSAGE_FRAME_INSERT_MODE_BOTTOM,
    }, {
      text = L['down'],
      value = SCROLLING_MESSAGE_FRAME_INSERT_MODE_TOP,
    },
  });

  optionMap.horizontalAlign = mainPanel:addDropdown(L['text alignment'], {
    {
      text = L['left'],
      value = 'LEFT',
    }, {
      text = L['center'],
      value = 'CENTER',
    }, {
      text = L['right'],
      value = 'RIGHT',
    },
  });

  optionMap.outline = mainPanel:addDropdown(L['outline mode'], {
    {
      text = L['None'],
      value = '',
    }, {
      text = L['Thin'],
      value = 'OUTLINE',
    }, {
      text = L['Thick'],
      value = 'THICKOUTLINE',
    }, {
      text = L['Monochrome'],
      value = 'MONOCHROME, OUTLINE',
    }, {
      text = L['Thick Monochrome'],
      value = 'MONOCHROME, THICKOUTLINE',
    }
  });

  mainPanel:addButton(L['reset position'], setDefaultPosition);
  mainPanel:addButton(L['move display'], moveFrame);

  mainPanel:mapOptions(options, optionMap);
  mainPanel:OnSave(applyOptions);
  mainPanel:OnCancel(applyOptions);
end

saved:OnLoad(function ()
  setFramePosition(options.anchor);
  farmerFrame:SetInsertMode(getProperInsertmode(options.insertMode));
  setFontOptions(options);
  setVisibleTime(options.displayTime);
  farmerFrame:SetJustifyH(options.horizontalAlign);
end);

--[[
///#############################################################################
/// slash commands
///#############################################################################
--]]

addon.slash('move', moveFrame);
addon.slash('reset', setDefaultPosition);

addon.slash('default', function ()
  return (Panel.openLastPanel() or mainPanel:open());
end);
