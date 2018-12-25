local addonName, farmerVars = ...

local currentVersion = 0205020

local rarityList = {
  [0] = 'Poor',
  'Common',
  'Uncommon',
  'Rare',
  'Epic',
  'Legendary',
  'Artifact',
  'Heirloom',
  'WoW Token'
}

local checkButtonList = {}
local sliderList = {}
local editBoxList = {}
local events = {}

farmerVars.rarityColors = {}
for i = 0, 8 do
  farmerVars.rarityColors[i] = {GetItemQualityColor(i)}
end

local farmerOptionsFrame = CreateFrame('Frame', 'farmerOptionsFrame', UIParent)
farmerOptionsFrame.name = 'Farmer'
InterfaceOptions_AddCategory(farmerOptionsFrame)

local function setDefaultPosition ()
  local frame = farmerVars.frame
  frame:ClearAllPoints()
  frame:SetPoint('BOTTOM', nil, 'CENTER', 0, 35)
end

local function storePosition (frame)
  local icon = GetItemIcon(114978)

  icon = ' |T' .. icon .. farmerVars.iconOffset
  farmerOptions.anchor = {frame:GetPoint()}
  frame:EnableMouse(false)
  frame:SetMovable(false)
  frame:SetFading(true)
  frame:Clear()
  frame:AddMessage(icon)
  frame:StopMovingOrSizing()
  frame:SetScript('OnDragStart', nil)
  frame:SetScript('OnReceiveDrag', nil)
end

local function moveFrame ()
  local frame = farmerVars.frame
  local icon = GetItemIcon(3334)

  icon = ' |T' .. icon .. farmerVars.iconOffset
  frame:RegisterForDrag('LeftButton')
  frame:SetFading(false)
  frame:Clear()
  frame:AddMessage(icon)
  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:SetScript('OnDragStart', function (self)
    if (self:IsMovable() == true) then
      self:StartMoving()
    end
  end)
  frame:SetScript('OnReceiveDrag', function (self)
    storePosition(self)
  end)
end

local function displayRarity (edit, rarity)
  local colorHex
  colorHex = farmerVars.rarityColors[rarity][4]
  edit:SetText('|c' .. colorHex .. rarityList[rarity])
  edit:SetCursorPosition(0)
end

local function setFontSize (size, scale)
  farmerVars.font:SetFont('Fonts\\FRIZQT__.TTF', size, 'thickoutline')
  -- adding line spacing makes textures completely off so they need y-offset
  -- for some reason that offset has to be 1.5 times the spacing
  -- i have no idea why, i just figured it out by testing
  farmerVars.font:SetSpacing(size / 9)
  farmerVars.iconOffset = ':'.. size * scale .. ':' .. size *scale .. ':' ..
                          '0:-' .. (size / 6) .. '|t '
  -- farmerVars.textOffset = ':'.. s .. ':' .. s .. ':' .. '0:-' .. (size / 6) .. '|t '
  -- farmerVars.iconOffset = ':0:0:0:-' .. (size / 6)  .. '|t '
end

local function createCheckButton (name, anchorFrame, xOffset, yOffset, text, anchor, parentAnchor)
  local checkButton = CreateFrame('CheckButton', name .. 'CheckButton', farmerOptionsFrame, 'OptionsCheckButtonTemplate')

  anchor = anchor or 'TOPLEFT'
  parentAnchor = parentAnchor or 'BOTTOMLEFT'

  checkButton:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset)
  _G[name .. 'CheckButtonText']:SetText(text)
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

local function createSlider (name, anchorFrame, xOffset, yOffset, text, min, max, lowText, highText, anchor, parentAnchor, onChange)
  local slider = CreateFrame('Slider', name .. 'Slider', farmerOptionsFrame, 'OptionsSliderTemplate')

  anchor = anchor or 'TOPLEFT'
  parentAnchor = parentAnchor or 'BOTTOMLEFT'

  slider:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset)
  slider:SetOrientation('HORIZONTAL')
  slider:SetMinMaxValues(min, max)
  slider:SetValueStep(1)
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
  local back = CreateFrame('Frame', name .. 'Back', anchorFrame);
  local edit = CreateFrame('EditBox', name .. 'EditBox', back);
  local scroll = CreateFrame('ScrollFrame', name .. 'ScrollFrame', back, 'UIPanelScrollFrameTemplate');

  back.scroll = scroll
  back.edit = edit
  anchor = anchor or 'TOPLEFT'
  parentAnchor = parentAnchor or 'TOPLEFT'

  back:SetBackdrop({
    -- bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background',
    edgeFile = 'Interface\\PVPFrame\\UI-Character-PVP-Highlight',
    edgeSize = 10,
    -- insets = { left = 20, right = 20, top = 20, bottom = 20 },
  });
  back:SetSize(width, height);
  back:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset);

  -- scroll:SetPoint("TOPLEFT", back, "TOPLEFT", 4, -4);
  -- scroll:SetPoint("BOTTOMRIGHT", back, "BOTTOMRIGHT", -4, 2);

  scroll:SetPoint('TOP', 0, -12);
  scroll:SetPoint('LEFT', 8, 0);
  scroll:SetPoint('RIGHT', -8, 0);
  scroll:SetPoint('BOTTOM', 0, 12);
  -- scroll:SetPoint('BOTTOM', back, 'BOTTOM', 0, 0);
  -- scroll:SetClipsChildren(true);

  edit:SetAutoFocus(false);
  edit:SetMultiLine(true);
  edit:EnableMouse(true);
  edit:SetMaxLetters(1000);
  -- edit:SetFontObject('ChatFontNormal');
  edit:SetFont('Fonts\\ARIALN.ttf', 16, 'THINOUTLINE');
  edit:SetWidth(width - 16);
  editBoxList[name] = edit;
  -- edit:SetHeight(height);
  -- edit:SetPoint('TOP', back, 'TOP', 0, 0);
  -- edit:SetPoint('TOPLEFT', back, 'TOPLEFT', 0, 0);
  -- edit:SetPoint('BOTTOM', back, 'BOTTOM', 0, 0);
  -- edit:SetPoint('BOTTOMRIGHT', back, 'BOTTOMRIGHT', 0, 0);
  -- edit:SetTextInsets(8, 8, 8, 8);
  edit:SetScript('OnEscapePressed', function ()
    edit:ClearFocus();
  end)
  edit:Show();
  scroll:SetScrollChild(edit);

  return back;
end

local function initPanel ()
  local anchor = farmerOptionsFrame
  local itemField

  anchor = createCheckButton('fastLoot', farmerOptionsFrame, 300, -15, 'enable fast autoloot', 'TOPLEFT', 'TOPLEFT')
  anchor = createCheckButton('itemNames', anchor, 0, -5, 'show names of all items')
  anchor = createCheckButton('hideLootToasts', anchor, 0, -5, 'hide loot and item roll toasts')
  anchor = createCheckButton('hideInArena', anchor, 0, -5, 'don\'t display items in arena')
  anchor = createCheckButton('hideOnExpeditions', anchor, 0, -5, 'don\'t display items on island expeditions')
  anchor = createCheckButton('showTotal', anchor, 0, -5, 'show total count for stackable items')
  anchor = createCheckButton('showBags', anchor, 0, -5, 'show bag count for stackable items')

  anchor = createCheckButton('rarity', farmerOptionsFrame, 15, -15, 'show items based on rarity', 'TOPLEFT', 'TOPLEFT')
  _, anchor = createSlider('minimumRarity', anchor, 20, -20, 'minimum rarity', 0, 8, '', '', 'TOPLEFT', 'BOTTOMLEFT', function (self, value)
    displayRarity(self.edit, value)
  end)
  anchor = createCheckButton('special', anchor, -20, -10, 'always show farming items')
  anchor = createCheckButton('reagents', anchor, 0, -5, 'always show reagents')
  anchor = createCheckButton('questItems', anchor, 0, -5, 'always show quest items')
  anchor = createCheckButton('currency', anchor, 0, -25, 'show currencies')
  anchor = createCheckButton('money', anchor, 0, -5, 'show money')

  anchor = createButton ('move', farmerOptionsFrame, 10, 12, 'move frame', 'BOTTOMLEFT', 'BOTTOMLEFT', function (self)
    moveFrame()
  end)
  createButton ('resetPosition', anchor, 20, 0, 'reset position', 'LEFT', 'RIGHT', function (self)
    setDefaultPosition()
    storePosition(farmerVars.frame)
  end)
  anchor = createSlider('fontSize', anchor, 3, 40, 'font size', 8, 64, '8', '64', 'BOTTOMLEFT', 'TOPLEFT', function (self, value)
    setFontSize(value, farmerOptions.iconScale)
  end)
  anchor = createSlider('iconScale', anchor, 3, 40, 'icon scale', 0.1, 3, '0.1', '3', 'BOTTOMLEFT', 'TOPLEFT', function (self, value)
  end)
  anchor:SetValueStep(0.1)
  createSlider('displayTime', anchor, 23, 0, 'display time', 1, 10, '1', '10', 'LEFT', 'RIGHT', function (self, value)
    farmerVars.frame:SetTimeVisible(value - farmerVars.frame:GetFadeDuration())
  end)

  itemField = createEditBox('focusItems', farmerOptionsFrame, -25, 25, 120, 200, 'BOTTOMRIGHT', 'BOTTOMRIGHT');
  anchor = itemField;
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
    AlertFrame:UnregisterEvent('BONUS_ROLL_RESULT')
  end

  if (farmerOptions.money == true) then
    farmerVars.moneyStamp = GetMoney()
  end

  setFontSize(farmerOptions.fontSize, farmerOptions.iconScale)
  farmerVars.frame:SetTimeVisible(farmerOptions.displayTime - farmerVars.frame:GetFadeDuration())
  -- farmerVars.frame:SetTimeVisible(farmerOptions.displayTime)
end

local function loadItemIds ()
  local list = farmerOptions['focusItems'];
  local edit = editBoxList['focusItems'];
  local text = {};

  for key in pairs(list) do
    table.insert(text, key);
  end

  edit:SetText(table.concat(text, '\n'));
end

local function loadOptions ()
  fontSize = nil
  iconScale = nil
  for k, v in pairs(checkButtonList) do
    v:SetChecked(farmerOptions[k])
  end
  for k, v in pairs(sliderList) do
    v:SetValue(farmerOptions[k])
  end

  loadItemIds()
end

local function saveItemIds ()
  local text = editBoxList['focusItems']:GetText();
  local list = {};

  text = {strsplit('\n', text)};

  for i = 1, #text do
    local line = text[i];

    if (line) then
      line = strtrim(line);

      if (line ~= '') then
        list[tonumber(line)] = true;
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

function events:ADDON_LOADED (addon)
  if (addon ~= 'Farmer') then
    return
  end

  initPanel()

  if (farmerOptions == nil) then
    farmerOptions = {}
    farmerOptions.version = currentVersion
  end

  if (farmerOptions.version == nil) then
    print('You seem to have used an old Version of Farmer\nCheck out all the new features in the options!')
  elseif (farmerOptions.version < currentVersion) then
    local version = GetAddOnMetadata(addonName, 'version')
    local text

    text = 'New in ' .. addonName .. ' version ' .. version .. ':\n' ..
           'Island Expeditions are now supported \nand can be enabled in the options.'
    print(text)
  end
  farmerOptions.version = currentVersion

  checkOption('fastLoot', true)
  checkOption('itemNames', true)
  checkOption('hideLootToasts', false)
  checkOption('hideInArena', true)
  checkOption('hideOnExpeditions', true)
  checkOption('showTotal', true)
  checkOption('showBags', false)
  checkOption('rarity', true)
  checkOption('minimumRarity', 3)
  checkOption('special', true)
  checkOption('reagents', true)
  checkOption('questItems', false)
  checkOption('currency', true)
  checkOption('money', false)
  checkOption('fontSize', 24)
  checkOption('iconScale', 1)
  checkOption('displayTime', 4)
  checkOption('focusItems', {})

  if (farmerOptions.anchor == nil) then
    setDefaultPosition()
  else
    farmerVars.frame:SetPoint(unpack(farmerOptions.anchor))
  end

  applyOptions()
end

function events:PLAYER_LOGIN ()
  local money = GetMoney()

  earningStamp = earningStamp or money

  if (farmerOptions.money == true) then
    farmerVars.moneyStamp = money
  end
end

local function eventHandler (self, event, ...)
  events[event](self, ...)
end

farmerOptionsFrame:SetScript('OnEvent', eventHandler)

for k, v in pairs(events) do
  farmerOptionsFrame:RegisterEvent(k)
end

--[[
///#############################################################################
/// slash commands
///#############################################################################
--]]

local slashCommands = {}

slashCommands['move'] = moveFrame

function slashCommands:reset ()
  setDefaultPosition()
  storePosition(farmerVars.frame)
end

function slashCommands:gold (param)
  if (param == 'reset') then
    earningStamp = GetMoney()
    print('Money counter was reset')
    return
  end
  local difference = GetMoney() - earningStamp
  local amount = math.abs(difference)
  local text

  text = (GOLD_AMOUNT_TEXTURE .. ' ' ..
          SILVER_AMOUNT_TEXTURE .. ' ' ..
          COPPER_AMOUNT_TEXTURE):format(amount / 10000, 0, 0,
                                        (amount / 100) % 100, 0, 0,
                                        amount % 100, 0, 0)
  if (difference >= 0) then
    print('Money earned this session: ' .. text)
  else
    print('You lost money this session: ' .. text)
  end
end

function slashCommands:default ()
  InterfaceOptionsFrame_Show()
  InterfaceOptionsFrame_OpenToCategory(farmerOptionsFrame)
end

local function slashHandler (input)
  local command, param = input.split(' ', input, 3)

  command = command == '' and 'default' or command
  command = string.lower(command or 'default')
  param = string.lower(param or '')

  if (slashCommands[command] ~= nil) then
    slashCommands[command](nil, param)
    return
  end
  print('Farmer: unknown command "' .. input .. '"')
end

SLASH_FARMER1 = '/farmer'
SlashCmdList.FARMER = slashHandler
