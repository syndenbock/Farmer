local addonName, addon = ...;

local Factory = {};

addon.OptionFactory = Factory;

do
  local Panel = {};
  local panelCount = 0;

  Panel.__index = Panel;

  local function getPanelName ()
    local panelName = addonName .. 'Panel' .. panelCount;

    panelCount = panelCount + 1;

    return panelName;
  end

  function Panel:New (name, parent)
    parent = parent or UIParent;

    local this = {};
    local panel = CreateFrame('Frame', getPanelName(), parent);

    setmetatable(this, Panel);

    this.parent = parent;
    this.name = name;
    this.panel = panel;
    this.anchor = {
      x = 10,
      y = 10,
    };

    panel.name = name;
    panel.parent = parent.name;

    InterfaceOptions_AddCategory(panel);

    this.anchor = {
      x = 10,
      y = -10,
    };

    this.childCount = 0;

    return this;
  end

  function Panel:getChildName ()
    local name = self.name .. 'child' .. self.childCount;

    self.childCount = self.childCount + 1;

    return name;
  end

  function Panel:addButton (text, onClick)
    local button = Factory.Button:New(self.panel, self:getChildName(), self.panel, self.anchor.x, self.anchor.y, text, 'TOPLEFT', 'TOPLEFT', onClick);

    self.anchor.y = self.anchor.y - 7 - button.button:GetHeight();

    return button;
  end

  function Panel:addCheckbox (text)
    local checkBox = Factory.CheckBox:New(self.panel, self:getChildName(), self.panel, self.anchor.x, self.anchor.y, text, 'TOPLEFT', 'TOPLEFT', onClick);

    self.anchor.y = self.anchor.y - 7 - checkBox.checkBox:GetHeight();

    return checkBox;
  end

  function Panel:addSlider (min, max, text, lowText, highText, stepSize)
    local slider = Factory.Slider:New(self.panel, self:getChildName(), self.panel, self.anchor.x, self.anchor.y, text, min, max, lowText, highText, 'TOPLEFT', 'TOPLEFT', stepSize);

    self.anchor.y = self.anchor.y - 7 - slider.slider:GetHeight();

    return slider;
  end

  Factory.Panel = Panel;
end

do
  local Button = {};

  Button.__index = Button;

  function Button:New (parent, name, anchorFrame, xOffset, yOffset, text, anchor, parentAnchor, onClick)
    local this = {};
    local button = CreateFrame('Button', name .. 'Button', parent, 'OptionsButtonTemplate');

    setmetatable(this, Button);

    this.button = button;

    anchor = anchor or 'TOPLEFT';
    parentAnchor = parentAnchor or 'BOTTOMLEFT';

    button:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset);
    button:SetSize(150, 25);
    button:SetText(text);

    if (onClick ~= nil) then
      this:onClick(onClick);
    end

    return this;
  end

  function Button:onClick (callback)
    self.button:SetScript('OnClick', callback);
  end

  Factory.Button = Button;
end

do
  local CheckBox = {};

  CheckBox.__index = CheckBox;

  function CheckBox:New (parent, name, anchorFrame, xOffset, yOffset, text, anchor, parentAnchor)
    local this = {};
    local checkBox = CreateFrame('CheckButton', name .. 'CheckButton', parent, 'OptionsCheckButtonTemplate')

    setmetatable(this, CheckBox);

    this.checkBox = checkBox;

    anchor = anchor or 'TOPLEFT';
    parentAnchor = parentAnchor or 'BOTTOMLEFT';

    checkBox:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset);

    -- Blizzard really knows how to write APIs. Not.
    _G[name .. 'CheckButtonText']:SetText(text);
    _G[name .. 'CheckButtonText']:SetJustifyH('LEFT');

    print(checkBox.Text);
    print(checkBox.text);

    -- Blizzard broke something in the BfA beta, so we have to fix it
    checkBox.SetValue = function (table, value)
      addon:printTable(table);
      print(value);
    end

    return this;
  end

  function CheckBox:GetValue ()
    return self.checkBox:GetChecked();
  end

  Factory.CheckBox = CheckBox;
end

do
  local Slider = {};

  Slider.__index = Slider;

  function Slider:New (parent, name, anchorFrame, xOffset, yOffset, text, min, max, lowText, highText, anchor, parentAnchor, stepSize)
    stepSize = stepSize or 1;

    local this = {};
    local slider = CreateFrame('Slider', name .. 'Slider', parent, 'OptionsSliderTemplate');
    local edit;

    setmetatable(this, Slider);

    this.slider = slider;
    this.edit = edit;

    anchor = anchor or 'TOPLEFT';
    parentAnchor = parentAnchor or 'BOTTOMLEFT';

    slider:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset);
    slider:SetOrientation('HORIZONTAL');
    slider:SetMinMaxValues(min, max);
    slider:SetValueStep(stepSize);
    slider:SetObeyStepOnDrag(true);
    _G[name .. 'SliderText']:SetText(text);
    _G[name .. 'SliderLow']:SetText(lowText);
    _G[name .. 'SliderHigh']:SetText(highText);

    slider:SetScript('OnValueChanged', function (self, value)
      value = math.floor((value * 10) + 0.5) / 10;
      self.edit:SetText(value);
      self.edit:SetCursorPosition(0);

      if (this.onChange ~= nil) then
        this.onChange(self, value);
      end
    end);

    anchor = slider;
    edit = CreateFrame('EditBox', name .. 'EditBox', parent);
    edit:SetAutoFocus(false);
    edit:Disable();
    edit:SetPoint('TOP', anchor, 'BOTTOM', 0, 0);
    edit:SetFontObject('ChatFontNormal');
    edit:SetHeight(20);
    edit:SetWidth(slider:GetWidth());
    edit:SetTextInsets(8, 8, 0, 0);
    edit:SetJustifyH('CENTER');
    edit:Show();
    -- edit:SetBackdrop(slider:GetBackdrop())
    -- edit:SetBackdropColor(0, 0, 0, 0.8)
    -- edit:SetBackdropBorderColor(1, 1, 1, 1)
    slider.edit = edit;

    return this;
  end

  function Slider:GetValue ()
    return self.edit:GetValue();
  end

  Factory.Slider = Slider;
end