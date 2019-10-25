local addonName, addon = ...;

local L = addon.L;
local currentVersion = 0210000;

local ADDON_ICON_ID = 3334;

local OUTLINE_OPTIONS = {
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
};

local checkButtonList = {}
local sliderList = {}
local editBoxList = {}
local dropdownList = {}

if (L.hasTranslation == true) then
  addon.vars.font = STANDARD_TEXT_FONT;
else
  addon.vars.font = 'Fonts\\FRIZQT__.ttf';
end

local farmerOptionsFrame = CreateFrame('Frame', 'farmerOptionsFrame', UIParent)
farmerOptionsFrame.name = 'Farmer'
InterfaceOptions_AddCategory(farmerOptionsFrame)

local function setDefaultPosition ()
  local frame = addon.frame
  frame:ClearAllPoints()
  frame:SetPoint('BOTTOM', nil, 'CENTER', 0, 50)
end

local function storePosition (frame)
  local icon = addon:getIcon(GetItemIcon(ADDON_ICON_ID));

  farmerOptions.anchor = {frame:GetPoint()};
  frame:EnableMouse(false);
  frame:SetMovable(false);
  frame:SetFading(true);
  frame:Clear();
  frame:AddMessage(icon);
  frame:StopMovingOrSizing();
  frame:SetScript('OnDragStart', nil);
  frame:SetScript('OnReceiveDrag', nil);
end

local function moveFrame ()
  local frame = addon.frame;
  local icon = addon:getIcon(GetItemIcon(ADDON_ICON_ID));

  frame:RegisterForDrag('LeftButton');
  frame:SetFading(false);
  frame:Clear();
  frame:AddMessage(icon);
  frame:EnableMouse(true);
  frame:SetMovable(true);
  frame:SetScript('OnDragStart', function (self)
    if (self:IsMovable() == true) then
      self:StartMoving();
    end
  end);
  frame:SetScript('OnReceiveDrag', function (self)
    storePosition(self);
  end);
end

local function displayRarity (edit, rarity)
  local colorHex = ITEM_QUALITY_COLORS[rarity].hex

  edit:SetText(colorHex .. _G['ITEM_QUALITY' .. rarity .. '_DESC'] .. '|r')
  edit:SetCursorPosition(0)
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

  -- addon.vars.iconOffset = ':'.. iconSize .. ':' .. iconSize .. ':' .. '0:' .. iconOffset;
  addon.vars.iconOffset = addon:stringJoin({'', iconSize, iconSize, '0', iconOffset}, ':');
end

local function createCheckButton (name, anchorFrame, xOffset, yOffset, text, anchor, parentAnchor)
  local checkButton = CreateFrame('CheckButton', name .. 'CheckButton', farmerOptionsFrame, 'OptionsCheckButtonTemplate')

  anchor = anchor or 'TOPLEFT'
  parentAnchor = parentAnchor or 'BOTTOMLEFT'

  checkButton:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset)
  _G[name .. 'CheckButtonText']:SetText(text)
  _G[name .. 'CheckButtonText']:SetJustifyH('LEFT')
  checkButtonList[name] = checkButton

  -- blizzard broke something in the bfa beta, so we have to fix it
  checkButton.SetValue = function () end

  return checkButton
end

local function createButton (name, anchorFrame, xOffset, yOffset, text, anchor, parentAnchor, onClick)
  local button = CreateFrame('Button', name .. 'Button', farmerOptionsFrame, 'OptionsButtonTemplate')

  anchor = anchor or 'TOPLEFT'
  parentAnchor = parentAnchor or 'BOTTOMLEFT'

  button:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset)
  button:SetWidth(150)
  button:SetHeight(25)
  button:SetText(text)

  if (onClick ~= nil) then
    button:SetScript('OnClick', onClick)
  end

  return button
end

local function createSlider (name, anchorFrame, xOffset, yOffset, text, min, max, lowText, highText, anchor, parentAnchor, onChange, stepSize)
  stepSize = stepSize or 1
  local slider = CreateFrame('Slider', name .. 'Slider', farmerOptionsFrame, 'OptionsSliderTemplate')
  local edit

  anchor = anchor or 'TOPLEFT'
  parentAnchor = parentAnchor or 'BOTTOMLEFT'

  slider:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset)
  slider:SetOrientation('HORIZONTAL')
  slider:SetMinMaxValues(min, max)
  slider:SetValueStep(stepSize)
  slider:SetObeyStepOnDrag(true)
  _G[name .. 'SliderText']:SetText(text)
  _G[name .. 'SliderLow']:SetText(lowText)
  _G[name .. 'SliderHigh']:SetText(highText)
  slider:SetScript('OnValueChanged', function (self, value)
    value = math.floor((value * 10) + 0.5) / 10
    self.edit:SetText(value)
    self.edit:SetCursorPosition(0)
    if (onChange ~= nil) then
      onChange(self, value)
    end
  end)
  sliderList[name] = slider
  anchor = slider
  edit = CreateFrame('EditBox', name .. 'EditBox', farmerOptionsFrame)
  edit:SetAutoFocus(false)
  edit:Disable()
  edit:SetPoint('TOP', anchor, 'BOTTOM', 0, 0)
  edit:SetFontObject('ChatFontNormal')
  edit:SetHeight(20)
  edit:SetWidth(slider:GetWidth())
  edit:SetTextInsets(8, 8, 0, 0)
  edit:SetJustifyH('CENTER')
  edit:Show()
  -- edit:SetBackdrop(slider:GetBackdrop())
  -- edit:SetBackdropColor(0, 0, 0, 0.8)
  -- edit:SetBackdropBorderColor(1, 1, 1, 1)
  slider.edit = edit

  return slider, edit
end

local function createEditBox (name, anchorFrame, xOffset, yOffset, width, height, anchor, parentAnchor)
  local back = CreateFrame('Frame', name .. 'Back', anchorFrame)
  local edit = CreateFrame('EditBox', name .. 'EditBox', back)
  local scroll = CreateFrame('ScrollFrame', name .. 'ScrollFrame', back, 'UIPanelScrollFrameTemplate')

  back.scroll = scroll
  back.edit = edit
  anchor = anchor or 'TOPLEFT'
  parentAnchor = parentAnchor or 'BOTTOMLEFT'

  back:SetBackdrop({
    -- bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\PVPFrame\\UI-Character-PVP-Highlight',
    edgeSize = 10,
    -- insets = { left = 20, right = 20, top = 20, bottom = 20 },
  })
  back:SetSize(width, height)
  back:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset)

  -- scroll:SetPoint("TOPLEFT", back, "TOPLEFT", 4, -4)
  -- scroll:SetPoint("BOTTOMRIGHT", back, "BOTTOMRIGHT", -4, 2)

  scroll:SetPoint('TOP', 0, -12)
  scroll:SetPoint('LEFT', 8, 0)
  scroll:SetPoint('RIGHT', -8, 0)
  scroll:SetPoint('BOTTOM', 0, 12)
  -- scroll:SetPoint('BOTTOM', back, 'BOTTOM', 0, 0)
  -- scroll:SetClipsChildren(true)

  edit:SetAutoFocus(false)
  edit:SetMultiLine(true)
  edit:EnableMouse(true)
  edit:SetMaxLetters(1000)
  -- edit:SetFontObject('ChatFontNormal')
  edit:SetFont(addon.vars.font, 16, 'THINOUTLINE')
  edit:SetWidth(width - 16)
  editBoxList[name] = edit
  -- edit:SetHeight(height)
  -- edit:SetPoint('TOP', back, 'TOP', 0, 0)
  -- edit:SetPoint('TOPLEFT', back, 'TOPLEFT', 0, 0)
  -- edit:SetPoint('BOTTOM', back, 'BOTTOM', 0, 0)
  -- edit:SetPoint('BOTTOMRIGHT', back, 'BOTTOMRIGHT', 0, 0)
  -- edit:SetTextInsets(8, 8, 8, 8)
  edit:SetScript('OnEscapePressed', function ()
    edit:ClearFocus()
  end)
  edit:Show()
  scroll:SetScrollChild(edit)

  return back
end

local function createLabel (anchorFrame, xOffset, yOffset, text, anchor, parentAnchor)
  local label = farmerOptionsFrame:CreateFontString('FontString')

  anchor = anchor or 'TOPLEFT'
  parentAnchor = parentAnchor or 'BOTTOMLEFT'

  label:SetFont(addon.vars.font, 16, 'outline')
  label:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset)
  label:SetText(text)

  return label
end

local function createDropdown (name, anchorFrame, xOffset, yOffset, text, options, anchor, parentAnchor)
  local dropdown = CreateFrame('Frame', name .. 'Dropdown', anchorFrame, 'UIDropDownMenuTemplate');
  local currentValue = farmerOptions[name];

  anchor = anchor or 'TOPLEFT';
  parentAnchor = parentAnchor or 'BOTTOMLEFT';

  dropdownList[name] = dropdown;

  dropdown:SetPoint(anchor, anchorFrame, parentAnchor, xOffset - 23, yOffset);

  UIDropDownMenu_SetWidth(dropdown, 138);
  UIDropDownMenu_SetText(dropdown, text);

  UIDropDownMenu_Initialize(dropdown, function (self, level, menuList)
    local info = UIDropDownMenu_CreateInfo();

    for i = 1, #options do
      local option = options[i];
      info.func = self.SetValue;

      info.text = option.text;
      info.arg1 = option.value;
      info.checked = (currentValue == option.value);
      UIDropDownMenu_AddButton(info, level);
    end
  end);

  function dropdown:SetValue (value)
    currentValue = value;
  end

  function dropdown:GetValue ()
    return currentValue;
  end

  return dropdown;
end

local function initPanel ()
  local anchor = farmerOptionsFrame
  local itemField

  anchor = createCheckButton('rarity', farmerOptionsFrame, 15, -15, L['show items based on rarity'], 'TOPLEFT', 'TOPLEFT')
  _, anchor = createSlider('minimumRarity', anchor, 20, -20, L['minimum rarity'], 0, 8, '', '', 'TOPLEFT', 'BOTTOMLEFT', function (self, value)
    displayRarity(self.edit, value)
  end)
  anchor = createCheckButton('reagents', anchor, -20, -5, L['always show reagents'])
  anchor = createCheckButton('questItems', anchor, 0, -5, L['always show quest items'])
  anchor = createCheckButton('recipes', anchor, 0, -5, L['always show recipes'])

  anchor = createCheckButton('showTotal', anchor, 0, -5, L['show total count for stackable items'])
  anchor = createCheckButton('showBags', anchor, 0, -5, L['show bag count for stackable items'])

  anchor = createCheckButton('currency', anchor, 0, -20, L['show currencies'])
  anchor = createCheckButton('ignoreHonor', anchor, 20, 0, L['ignore Honor'])
  anchor = createCheckButton('reputation', anchor, -20, -5, L['show reputation'])
  anchor = createCheckButton('money', anchor, 0, -5, L['show money'])

  anchor = createCheckButton('fastLoot', farmerOptionsFrame, 330, -15, L['enable fast autoloot'], 'TOPLEFT', 'TOPLEFT')
  anchor = createCheckButton('itemNames', anchor, 0, -5, L['show names of all items'])
  anchor = createCheckButton('hideLootToasts', anchor, 0, -5, L['hide loot and item roll toasts'])
  anchor = createCheckButton('hidePlatesWhenFishing', anchor, 0, -5, L['hide health bars while fishing'])

  anchor = createCheckButton('hideAtMailbox', anchor, 0, -20, L['don\'t display at mailboxes'])
  anchor = createCheckButton('hideInArena', anchor, 0, -5, L['don\'t display in arena'])
  anchor = createCheckButton('hideOnExpeditions', anchor, 0, -5, L['don\'t display on island expeditions'])

  anchor = createButton ('move', farmerOptionsFrame, 10, 12, L['move display'], 'BOTTOMLEFT', 'BOTTOMLEFT', function (self)
    moveFrame()
  end)
  createButton ('resetPosition', anchor, 20, 0, L['reset position'], 'LEFT', 'RIGHT', function (self)
    setDefaultPosition()
    storePosition(addon.frame)
  end)
  anchor = createSlider('iconScale', anchor, 3, 40, L['icon scale'], 0.1, 3, '0.1', '3', 'BOTTOMLEFT', 'TOPLEFT', function (self, value)
  end, 0.1)
  anchor = createSlider('fontSize', anchor, 3, 40, L['font size'], 8, 64, '8', '64', 'BOTTOMLEFT', 'TOPLEFT', function (self, value)
    setFontSize(value, farmerOptions.iconScale, farmerOptions.outline)
  end)
  anchor = createSlider('displayTime', anchor, 23, 0, L['display time'], 1, 10, '1', '10', 'LEFT', 'RIGHT', function (self, value)
    addon.frame:SetTimeVisible(value - addon.frame:GetFadeDuration())
  end)

  createDropdown('outline', anchor, 0, -40, L['outline mode'], OUTLINE_OPTIONS, 'TOPLEFT', 'BOTTOMLEFT')

  itemField = createEditBox('focusItems', farmerOptionsFrame, -80, 100, 150, 200, 'BOTTOMRIGHT', 'BOTTOMRIGHT')
  anchor = itemField

  createLabel(anchor, 0, 0, L['focused item ids:'], 'BOTTOMLEFT', 'TOPLEFT')

  anchor = createCheckButton('special', anchor, 0, -5, L['always show focused items'], 'TOPLEFT', 'BOTTOMLEFT')
  anchor = createCheckButton('focus', anchor, 0, -5, L['only show focused items'])
end

local function applyOptions ()
  if (farmerOptions.hideLootToasts == true) then
    AlertFrame:UnregisterEvent('SHOW_LOOT_TOAST')
    AlertFrame:UnregisterEvent('LOOT_ITEM_ROLL_WON')
    AlertFrame:UnregisterEvent('SHOW_LOOT_TOAST_UPGRADE')
    AlertFrame:UnregisterEvent('BONUS_ROLL_RESULT')
  else
    AlertFrame:RegisterEvent('SHOW_LOOT_TOAST')
    AlertFrame:RegisterEvent('LOOT_ITEM_ROLL_WON')
    AlertFrame:RegisterEvent('SHOW_LOOT_TOAST_UPGRADE')
    AlertFrame:RegisterEvent('BONUS_ROLL_RESULT')
  end

  if (farmerOptions.money == true) then
    addon.vars.moneyStamp = GetMoney()
  end

  setFontSize(farmerOptions.fontSize, farmerOptions.iconScale, farmerOptions.outline)
  addon.frame:SetTimeVisible(farmerOptions.displayTime - addon.frame:GetFadeDuration())
  -- addon.frame:SetTimeVisible(farmerOptions.displayTime)
end

local function loadItemIds ()
  local list = farmerOptions['focusItems']
  local edit = editBoxList['focusItems']
  local text = {}

  for key in pairs(list) do
    text[#text + 1] = key;
  end

  edit:SetText(table.concat(text, '\n'))
end

local function loadOptions ()
  for k, v in pairs(checkButtonList) do
    v:SetChecked(farmerOptions[k])
  end
  for k, v in pairs(sliderList) do
    v:SetValue(farmerOptions[k])
  end

  loadItemIds()
end

local function saveItemIds ()
  local text = editBoxList['focusItems']:GetText()
  local list = {}

  text = {string.split('\n', text)}

  for i = 1, #text do
    local line = text[i]

    if (line) then
      line = strtrim(line)

      if (line ~= '') then
        list[tonumber(line)] = true
      end
    end
  end

  farmerOptions['focusItems'] = list
end

local function saveOptions ()
  for k, v in pairs(checkButtonList) do
    farmerOptions[k] = v:GetChecked()
  end
  for k, v in pairs(sliderList) do
    farmerOptions[k] = v:GetValue()
  end
  for k, v in pairs(dropdownList) do
    farmerOptions[k] = v:GetValue()
  end

  saveItemIds()
  applyOptions()
end

farmerOptionsFrame.okay = saveOptions
farmerOptionsFrame.refresh = loadOptions
farmerOptionsFrame.cancel = applyOptions

function checkOption (name, default)
  if (farmerOptions[name] == nil) then
    farmerOptions[name] = default
  end
end

addon:on('PLAYER_LOGIN', function (name)
  if (farmerOptions == nil) then
    farmerOptions = {}
    farmerOptions.version = currentVersion
  end

  if (farmerOptions.version == nil) then
    print(L['You seem to have used an old Version of Farmer\nCheck out all the new features in the options!'])
  elseif (farmerOptions.version < currentVersion) then
    local version = GetAddOnMetadata(addonName, 'version')
    local text

    text = 'New in ' .. addonName .. ' version ' .. version .. ':\n' ..
           '- You can automatically put pets you own 3 times in a cage using "/farmer cagepets"\n' ..
           '- There is now an option to display reputation. This even shows a star when you earn a paragon reward!'
    print(text)
  end

  farmerOptions.version = currentVersion

  checkOption('fastLoot', true)
  checkOption('itemNames', true)
  checkOption('hideLootToasts', false)
  checkOption('hidePlatesWhenFishing', true)
  checkOption('hideAtMailbox', true)
  checkOption('hideInArena', true)
  checkOption('hideOnExpeditions', true)
  checkOption('showTotal', true)
  checkOption('showBags', false)
  checkOption('rarity', true)
  checkOption('minimumRarity', 2)
  checkOption('special', true)
  checkOption('focus', false)
  checkOption('reagents', true)
  checkOption('questItems', true)
  checkOption('recipes', false)
  checkOption('currency', true)
  checkOption('ignoreHonor', true)
  checkOption('reputation', true)
  checkOption('money', false)
  checkOption('fontSize', 18)
  checkOption('iconScale', 0.8)
  checkOption('displayTime', 4)
  checkOption('outline', 'OUTLINE')
  checkOption('focusItems', {})

  if (farmerOptions.anchor == nil) then
    setDefaultPosition()
  else
    addon.frame:SetPoint(unpack(farmerOptions.anchor))
  end

  local money = GetMoney()

  earningStamp = earningStamp or money

  if (farmerOptions.money == true) then
    addon.vars.moneyStamp = money
  end

  initPanel()
  applyOptions()
end);

--[[
///#############################################################################
/// slash commands
///#############################################################################
--]]

addon:slash('move', moveFrame)

addon:slash('reset', function ()
  setDefaultPosition()
  storePosition(addon.frame)
end)

addon:slash('gold', function (param)
  if (param == 'reset') then
    earningStamp = GetMoney()
    print(L['Money counter was reset'])
    return
  end
  local difference = GetMoney() - earningStamp
  local text = GetCoinTextureString(math.abs(difference))

  if (difference >= 0) then
    print(L['Money earned this session: '] .. text)
  else
    print(L['Money lost this session: '] .. text)
  end
end)

addon:slash('default', function ()
  InterfaceOptionsFrame_Show()
  InterfaceOptionsFrame_OpenToCategory(farmerOptionsFrame)
end)
