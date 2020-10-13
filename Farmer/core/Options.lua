local addonName, addon = ...;

local unpack = _G.unpack;
local GetItemIcon = _G.GetItemIcon;
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT;
-- for some reason they are not strings but numbers unlike MessageFrame modes

local L = addon.L;
local addonVars = addon.share('vars');

local ADDON_ICON_ID = 3334;
local ANCHOR_DEFAULT = {'BOTTOM', nil, 'CENTER', 0, 50};

local Panel = addon.OptionClass.Panel;
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
      hideOnExpeditions = true,
      itemNames = true,
      horizontalAlign = farmerFrame.ALIGNMENT_CENTER,
    },
  },
});

local options = saved.vars.farmerOptions.Core;

local function getAddonIcon ()
  --[[ this cannot be done on file load, as the icons are not ready yet ]]
  return addon.getIcon(GetItemIcon(ADDON_ICON_ID));
end

local function storePosition ()
  options.anchor = {farmerFrame:GetPoint()};
end

local function moveFrame ()
  farmerFrame:Move(getAddonIcon(), storePosition);
end

local function setFramePosition (position)
  farmerFrame:ClearAllPoints();
  farmerFrame:SetPoint(unpack(position));
end

local function setDefaultPosition ()
  setFramePosition(ANCHOR_DEFAULT);
  storePosition();
  farmerFrame:AddAnchorMessage(getAddonIcon());
end

local function setFontOptions (options)
  local shadowOffset = addon.round(options.fontSize / 10);
  local iconSize = addon.round(options.fontSize * options.iconScale / 1.5);

  --[[ we have to use the standard font because on screen messages are always
       localized --]]
  farmerFrame:SetFont(STANDARD_TEXT_FONT, options.fontSize, options.outline);
  farmerFrame:SetShadowOffset(shadowOffset, -shadowOffset);
  farmerFrame:SetSpacing(options.spacing);
  addonVars.iconOffset = addon.stringJoin({'', iconSize, iconSize}, ':');
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

local function checkOptions ()
  if (not options.anchor) then
    local message = addonName .. ' has reset its position because of internal changes, please reposition it';

    options.anchor = ANCHOR_DEFAULT;
    print(message);
    addon.frame:AddMessage(message);
  end
end

saved:OnLoad(function ()
  checkOptions();

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
