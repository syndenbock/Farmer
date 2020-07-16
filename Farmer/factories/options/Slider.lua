local _, addon = ...;

local CreateFrame = _G.CreateFrame;

local Factory = addon.share('OptionFactory');

local Slider = {};

Factory.Slider = Slider;

Slider.__index = Slider;

local function createEditBox (name, parent)
  local edit = CreateFrame('EditBox', name .. 'EditBox', parent);

  edit:SetAutoFocus(false);
  edit:Disable();
  edit:SetPoint('TOP', parent, 'BOTTOM', 0, 0);
  edit:SetFontObject('ChatFontNormal');
  edit:SetHeight(20);
  edit:SetWidth(parent:GetWidth());
  edit:SetTextInsets(8, 8, 0, 0);
  edit:SetJustifyH('CENTER');
  edit:Show();
  -- edit:SetBackdrop(slider:GetBackdrop())
  -- edit:SetBackdropColor(0, 0, 0, 0.8)
  -- edit:SetBackdropBorderColor(1, 1, 1, 1)

  return edit;
end

local function createSlider (name, parent, values, text, anchors)
  local slider = CreateFrame('Slider', name .. 'Slider', parent,
      'OptionsSliderTemplate');

  slider:SetPoint(anchors.anchor, anchors.parent, anchors.parentAnchor,
      anchors.xOffset, anchors.yOffset);
  slider:SetOrientation('HORIZONTAL');
  slider:SetMinMaxValues(values.min, values.max);
  slider:SetValueStep(values.stepSize);
  slider:SetObeyStepOnDrag(true);

  _G[name .. 'SliderText']:SetText(text.label);
  _G[name .. 'SliderLow']:SetText(text.low);
  _G[name .. 'SliderHigh']:SetText(text.high);

  slider:SetScript('OnValueChanged', function (self, value)
    value = math.floor((value * 10) + 0.5) / 10;

    if (self.edit) then
      self.edit:SetText(value);
      self.edit:SetCursorPosition(0);
    end

    if (self.onChange) then
      self:onChange(value);
    end
  end);

  function slider:OnChange (callback)
    self.onChange = callback;
  end

  return slider;
end

local function createSliderWithEditBox (name, parent, values, text, anchors)
  local slider = createSlider(name, parent, values, text, anchors);
  local edit = createEditBox(name, slider);

  slider.edit = edit;

  return slider, edit;
end

function Slider:new (parent, name, anchorFrame, xOffset, yOffset, text, min,
                     max, lowText, highText, anchor, parentAnchor, stepSize)
  local this = {};

  setmetatable(this, Slider);

  this.slider, this.edit = createSliderWithEditBox(name, parent, {
    stepSize = stepSize or 1,
    min = min,
    max = max,
  }, {
    label = text,
    low = lowText,
    high = highText,
  }, {
    anchor = anchor or 'TOPLEFT',
    parent = anchorFrame,
    parentAnchor = parentAnchor or 'BOTTOMLEFT',
    xOffset = xOffset,
    yOffset = yOffset,
  });

  return this;
end

function Slider:GetValue ()
  return self.slider:GetValue();
end

function Slider:SetValue (value)
  self.slider:SetValue(value);
end

function Slider:OnChange (callback)
  self.slider:OnChange(callback);
end

function Slider:GetHeight ()
  return self.slider:GetHeight() + self.edit:GetHeight();
end
