local addonName, addon = ...;

local unpack = _G.unpack;
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT;

local L = addon.L;

local ADDON_ICON_ID = 134435;
local ANCHOR_DEFAULT = {'BOTTOM', nil, 'CENTER', 0, 50};

local Panel = addon.import('Class/Options/Panel');
local mainPanel = Panel:new(addonName);
local farmerFrame = addon.frame;

addon.mainPanel = mainPanel.panel;

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Core = {
      anchor = ANCHOR_DEFAULT,
      insertMode = farmerFrame.GROW_DIRECTION_UP,
      displayTime = 4,
      fontSize = 24,
      iconScale = 1,
      spacing = 2,
      outline = 'OUTLINE',
      hideAtMailbox = true,
      hideInArena = true,
      itemNames = true,
      horizontalAlign = farmerFrame.ALIGNMENT_CENTER,
    },
  },
});

local options = saved.vars.farmerOptions.Core;

local function storePosition ()
  local coords = addon.getFrameRelativeCoords(farmerFrame);

  options.anchor = {
    'CENTER',
    'UIParent',
    'CENTER',
    coords.x,
    coords.y,
  };
end

local function moveFrame ()
  farmerFrame:Move(ADDON_ICON_ID, addonName .. ' Anchor', storePosition);
end

local function setFramePosition (position)
  farmerFrame:ClearAllPoints();
  farmerFrame:SetPoint(unpack(position));
end

local function setDefaultPosition ()
  setFramePosition(ANCHOR_DEFAULT);
  storePosition();
  farmerFrame:AddAnchorMessage(ADDON_ICON_ID);
end

local function setFontOptions (options)
  --[[ we have to use the standard font because on screen messages are always
       localized --]]
  farmerFrame:SetFont(STANDARD_TEXT_FONT, options.fontSize, options.outline);
  farmerFrame:SetSpacing(options.spacing);
  farmerFrame:SetIconScale(options.iconScale);
end

local function setVisibleTime (displayTime)
  farmerFrame:SetVisibleTime(displayTime - farmerFrame:GetFadeDuration());
end

local function applyOptions ()
  setFontOptions(options);
  farmerFrame:SetGrowDirection(options.insertMode);
  setVisibleTime(options.displayTime);
  farmerFrame:SetTextAlign(options.horizontalAlign);
end

do
  local optionMap = {};

  optionMap.itemNames = mainPanel:addCheckBox(L['always show names']);
  optionMap.hideAtMailbox = mainPanel:addCheckBox(L['don\'t display at mailboxes']);

  if (addon.isRetail()) then
    optionMap.hideInArena = mainPanel:addCheckBox(L['don\'t display in arena']);
  end

  optionMap.fontSize = mainPanel:addSlider(8, 64, L['font size'], '8', '64', 0);
  optionMap.iconScale = mainPanel:addSlider(0.1, 3, L['icon scale'], '0.1', '3', 1);
  optionMap.displayTime = mainPanel:addSlider(1, 60, L['display time'], '1', '60', 0);
  optionMap.spacing = mainPanel:addSlider(0, 20, L['line spacing'], '0', '20', 0);

  optionMap.insertMode = mainPanel:addDropdown(L['grow direction'], {
    {
      text = L['up'],
      value = farmerFrame.GROW_DIRECTION_UP,
    }, {
      text = L['down'],
      value = farmerFrame.GROW_DIRECTION_DOWN,
    },
  });

  optionMap.horizontalAlign = mainPanel:addDropdown(L['text alignment'], {
    {
      text = L['left'],
      value = farmerFrame.ALIGNMENT_LEFT,
    }, {
      text = L['center'],
      value = farmerFrame.ALIGNMENT_CENTER,
    }, {
      text = L['right'],
      value = farmerFrame.ALIGNMENT_RIGHT,
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
  applyOptions();
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
