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
local addonVars = addon:share('vars');

local VERSION_CURRENT = 0300000;
local ADDON_ICON_ID = 3334;
local VERSION_TOC = GetAddOnMetadata(addonName, 'version');
local ANCHOR_DEFAULT = {'BOTTOM', nil, 'CENTER', 0, 50};

if (L.hasTranslation == true) then
  addonVars.font = STANDARD_TEXT_FONT;
else
  addonVars.font = 'Fonts\\FRIZQT__.ttf';
end

local Factory = addon.OptionFactory;
local mainPanel = Factory.Panel:New(addonName);
local farmerFrame = addon.frame;

addon.mainPanel = mainPanel.panel;

local saved = addon.SavedVariablesHandler(addonName, {'earningStamp', 'farmerOptions'}, {
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

addon.savedVariables = saved.vars;

local function storePosition ()
  local icon = addon:getIcon(GetItemIcon(ADDON_ICON_ID));

  saved.vars.farmerOptions.anchor = {farmerFrame:GetPoint()};
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
  local icon = addon:getIcon(GetItemIcon(ADDON_ICON_ID));

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

local function setDefaultPosition ()
  farmerFrame:ClearAllPoints();
  farmerFrame:SetPoint(unpack(ANCHOR_DEFAULT));
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

  --[[ we have to use the standard font because on screen messages are always
       localized --]]
  addon.font:SetFont(STANDARD_TEXT_FONT, size, outline);
  addon.font:SetSpacing(spacing);
  addon.font:SetShadowColor(0, 0, 0);
  addon.font:SetShadowOffset(shadowOffset, -shadowOffset);

  -- addonVars.iconOffset = ':'.. iconSize .. ':' .. iconSize .. ':' .. '0:' .. iconOffset;
  addonVars.iconOffset = addon:stringJoin({'', iconSize, iconSize, '0', iconOffset}, ':');
end

local function applyOptions ()
  local options = saved.vars.farmerOptions;

  if (options.hideLootToasts == true) then
    if (not addon:isClassic()) then
      AlertFrame:UnregisterEvent('SHOW_LOOT_TOAST')
      AlertFrame:UnregisterEvent('SHOW_LOOT_TOAST_UPGRADE')
      AlertFrame:UnregisterEvent('BONUS_ROLL_RESULT')
    end

    AlertFrame:UnregisterEvent('LOOT_ITEM_ROLL_WON')
  else
    if (not addon:isClassic()) then
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
  local totalBox = mainPanel:addCheckBox(L['show total count for stackable items']);
  local bagBox = mainPanel:addCheckBox(L['show bag count for stackable items']);
  local nameBox = mainPanel:addCheckBox(L['show names of all items']);
  local toastBox = mainPanel:addCheckBox(L['hide loot and item roll toasts']);
  local mailBox = mainPanel:addCheckBox(L['don\'t display at mailboxes']);
  local arenaBox;
  local expeditionBox;

  if (not addon:isClassic()) then
    arenaBox = mainPanel:addCheckBox(L['don\'t display in arena']);
    expeditionBox = mainPanel:addCheckBox(L['don\'t display on island expeditions']);
  end

  local scaleSlider = mainPanel:addSlider(0.1, 3, L['icon scale'], '0.1', '3', 0.1);
  local sizeSlider = mainPanel:addSlider(8, 64, L['font size'], '8', '64', 1, function (_, value)
    setFontSize(value, saved.vars.farmerOptions.iconScale, saved.vars.farmerOptions.outline);
  end);
  local timeSlider = mainPanel:addSlider(1, 10, L['display time'], '1', '10', 1, function (_, value)
    farmerFrame:SetTimeVisible(value - farmerFrame:GetFadeDuration());
  end);
  local outLineDrop = mainPanel:addDropdown(L['outline mode'], {
    {
      text = L['None'],
      value = nil,
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
  local _ = mainPanel:addButton(L['reset position'], setDefaultPosition);
  local _ = mainPanel:addButton(L['move display'], moveFrame);

  mainPanel:OnLoad(function ()
    local options = saved.vars.farmerOptions;

    totalBox:SetValue(options.showTotal);
    bagBox:SetValue(options.showBags);
    nameBox:SetValue(options.itemNames);
    toastBox:SetValue(options.hideLootToasts);
    mailBox:SetValue(options.hideAtMailbox);

    if (not addon:isClassic()) then
      arenaBox:SetValue(options.hideInArena);
      expeditionBox:SetValue(options.hideOnExpeditions);
    end

    scaleSlider:SetValue(options.iconScale);
    sizeSlider:SetValue(options.fontSize);
    timeSlider:SetValue(options.displayTime);
    outLineDrop:SetValue(options.outline);
  end);

  mainPanel:OnSave(function ()
    local options = saved.vars.farmerOptions;

    options.showTotal = totalBox:GetValue();
    options.showBags = bagBox:GetValue();
    options.itemNames = nameBox:GetValue();
    options.hideLootToasts = toastBox:GetValue();
    options.hideAtMailbox = mailBox:GetValue();

    if (not addon:isClassic()) then
      options.hideInArena = arenaBox:GetValue();
      options.hideOnExpeditions = expeditionBox:GetValue();
    end

    options.iconScale = scaleSlider:GetValue();
    options.fontSize = sizeSlider:GetValue();
    options.displayTime = timeSlider:GetValue();
    options.outline = outLineDrop:GetValue();

    applyOptions();
  end);

  mainPanel:OnCancel(applyOptions);

  applyOptions();
end

saved:OnLoad(function (vars)
  local options = vars.farmerOptions;

  vars.farmerOptions = vars.farmerOptions or {};

  if (options.version < VERSION_CURRENT) then
    local text

    text = 'New in ' .. addonName .. ' version ' .. VERSION_TOC .. ':\n' ..
           '- Options have been cleaned up and are now separated into categories! \n' ..
           '- Farmer now has an API for plugins, a wiki will be created soon';
    print(text)
  end

  options.version = VERSION_CURRENT;

  farmerFrame:ClearAllPoints();
  farmerFrame:SetPoint(unpack(options.anchor));
  initPanel();
end);

--[[
///#############################################################################
/// slash commands
///#############################################################################
--]]

addon:slash('move', moveFrame);
addon:slash('reset', setDefaultPosition);

addon:slash('version', function ()
  print(addonName .. ' version ' .. VERSION_TOC);
end);

addon:slash('default', function ()
  InterfaceOptionsFrame_Show();
  InterfaceOptionsFrame_OpenToCategory(mainPanel.panel);
end);
