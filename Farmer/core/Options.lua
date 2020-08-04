local addonName, addon = ...;

local unpack = _G.unpack;
local max = _G.max;
local min = _G.min;
local GetAddOnMetadata = _G.GetAddOnMetadata;
local GetItemIcon = _G.GetItemIcon;
local InterfaceOptionsFrame_Show = _G.InterfaceOptionsFrame_Show;
local InterfaceOptionsFrame_OpenToCategory = _G.InterfaceOptionsFrame_OpenToCategory;
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT;
local AlertFrame = _G.AlertFrame;

local L = addon.L;
local addonVars = addon.share('vars');

local VERSION_CURRENT = 0301000;
local ADDON_ICON_ID = 3334;
local VERSION_TOC = GetAddOnMetadata(addonName, 'version');
local ANCHOR_DEFAULT = {'BOTTOM', nil, 'CENTER', 0, 50};

local Factory = addon.OptionClass;
local mainPanel = Factory.Panel:new(addonName);
local farmerFrame = addon.Print.frame;

addon.mainPanel = mainPanel.panel;

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    anchor = ANCHOR_DEFAULT,
    displayTime = 4,
    fontSize = 18,
    hideAtMailbox = true,
    hideInArena = true,
    hideLootToasts = false,
    hideOnExpeditions = true,
    iconScale = 0.8,
    itemNames = true,
    outline = 'OUTLINE',
    showBags = false,
    showTotal = true,
    version = VERSION_CURRENT,
  },
});

local options = saved.vars.farmerOptions;

local function storePosition ()
  local icon = addon.getIcon(GetItemIcon(ADDON_ICON_ID));

  options.anchor = {farmerFrame:GetPoint()};
  farmerFrame:EnableMouse(false);
  farmerFrame:SetMovable(false);
  farmerFrame:SetFading(true);
  farmerFrame:Clear();
  farmerFrame:AddMessage(icon);
  farmerFrame:StopMovingOrSizing();
  farmerFrame:SetScript('OnDragStart', nil);
  farmerFrame:SetScript('OnReceiveDrag', nil);
end

local function moveFrame ()
  local icon = addon.getIcon(GetItemIcon(ADDON_ICON_ID));

  farmerFrame:RegisterForDrag('LeftButton');
  farmerFrame:SetFading(false);
  farmerFrame:Clear();
  farmerFrame:AddMessage(icon);
  farmerFrame:EnableMouse(true);
  farmerFrame:SetMovable(true);
  farmerFrame:SetScript('OnDragStart', function (self)
    if (self:IsMovable() == true) then
      self:StartMoving();
    end
  end);

  farmerFrame:SetScript('OnReceiveDrag', storePosition);
end

local function setFramePosition (position)
  farmerFrame:ClearAllPoints();
  farmerFrame:SetPoint(unpack(position));
end

local function setDefaultPosition ()
  setFramePosition(ANCHOR_DEFAULT);
  storePosition();
end

local function setFontSize (size, scale, outline)
  -- adding line spacing makes textures completely off so they need y-offset
  -- for some reason that offset has to be 1.5 times the spacing
  -- i have no idea why, i just figured it out by testing
  local maximumIconSize = 128;
  local minimumIconSize = 8;
  local iconSize = max(min(size * scale, maximumIconSize), minimumIconSize);
  local spacing = 0;
  local iconOffset = -spacing * 1.5;
  local shadowOffset = size / 10;
  local font = addon.Print.font;

  --[[ we have to use the standard font because on screen messages are always
       localized --]]
  font:SetFont(STANDARD_TEXT_FONT, size, outline);
  font:SetSpacing(spacing);
  font:SetShadowColor(0, 0, 0);
  font:SetShadowOffset(shadowOffset, -shadowOffset);

  addonVars.iconOffset = addon.stringJoin({'', iconSize, iconSize, '0', iconOffset}, ':');
end

local function applyOptions ()
  if (options.hideLootToasts == true) then
    if (not addon.isClassic()) then
      AlertFrame:UnregisterEvent('SHOW_LOOT_TOAST')
      AlertFrame:UnregisterEvent('SHOW_LOOT_TOAST_UPGRADE')
      AlertFrame:UnregisterEvent('BONUS_ROLL_RESULT')
    end

    AlertFrame:UnregisterEvent('LOOT_ITEM_ROLL_WON')
  else
    if (not addon.isClassic()) then
      AlertFrame:RegisterEvent('SHOW_LOOT_TOAST')
      AlertFrame:RegisterEvent('SHOW_LOOT_TOAST_UPGRADE')
      AlertFrame:RegisterEvent('BONUS_ROLL_RESULT')
    end

    AlertFrame:RegisterEvent('LOOT_ITEM_ROLL_WON')
  end

  setFontSize(options.fontSize, options.iconScale, options.outline);
  farmerFrame:SetTimeVisible(options.displayTime -
      farmerFrame:GetFadeDuration());
end

local function initPanel ()
  local optionMap = {};

  optionMap.showTotal = mainPanel:addCheckBox(L['show total count for stackable items']);
  optionMap.showBags = mainPanel:addCheckBox(L['show bag count for stackable items']);
  optionMap.itemNames = mainPanel:addCheckBox(L['show names of all items']);
  optionMap.hideLootToasts = mainPanel:addCheckBox(L['hide loot and item roll toasts']);
  optionMap.hideAtMailbox = mainPanel:addCheckBox(L['don\'t display at mailboxes']);

  if (not addon.isClassic()) then
    optionMap.hideInArena = mainPanel:addCheckBox(L['don\'t display in arena']);
    optionMap.hideOnExpeditions = mainPanel:addCheckBox(L['don\'t display on island expeditions']);
  end

  optionMap.iconScale = mainPanel:addSlider(0.1, 3, L['icon scale'], '0.1', '3', 0.1);
  optionMap.fontSize = mainPanel:addSlider(8, 64, L['font size'], '8', '64', 1, function (_, value)
    setFontSize(value, options.iconScale, options.outline);
  end);
  optionMap.displayTime = mainPanel:addSlider(1, 10, L['display time'], '1', '10', 1, function (_, value)
    farmerFrame:SetTimeVisible(value - farmerFrame:GetFadeDuration());
  end);
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
  mainPanel:OnLoad(applyOptions);
  mainPanel:OnCancel(applyOptions);

  applyOptions();
end

saved:OnLoad(function ()
  if (options.version < VERSION_CURRENT) then
    local text

    text = 'New in ' .. addonName .. ' version ' .. VERSION_TOC .. ':\n' ..
           '- Farmer can now automatically sell gray items and repair your gear when you visit a vendor\n' ..
           '- The farm radar now has some options for toggling nodes and tooltips\n' ..
           'Make sure to check out those new features in the options!';
    print(text)
  end

  options.version = VERSION_CURRENT;

  setFramePosition(options.anchor);
  initPanel();
end);

--[[
///#############################################################################
/// slash commands
///#############################################################################
--]]

addon.slash('move', moveFrame);
addon.slash('reset', setDefaultPosition);

addon.slash('version', function ()
  print(addonName .. ' version ' .. VERSION_TOC);
end);

addon.slash('default', function ()
  InterfaceOptionsFrame_Show();
  InterfaceOptionsFrame_OpenToCategory(mainPanel.panel);
end);
