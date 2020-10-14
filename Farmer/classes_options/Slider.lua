local _, addon = ...;

local CreateFrame = _G.CreateFrame;
local BACKDROP_TEMPLATE = _G.BackdropTemplateMixin and 'BackdropTemplate';

local Factory = addon.share('OptionClass');

local Slider = {};

Factory.Slider = Slider;

Slider.__index = Slider;

local function createEditBox (name, parent)
  local edit = CreateFrame('EditBox', name .. 'EditBox', parent,
      BACKDROP_TEMPLATE);

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

local function setSliderOnChange (slider, callback)
  slider.onChange = callback;
end

local function sliderOnValueChanged (slider, value)
  value = addon.truncate(value, addon.stepSizeToPrecision(slider:GetValueStep()));

  if (slider.edit) then
    slider.edit:SetText(value);
    slider.edit:SetCursorPosition(0);
  end

  if (slider.onChange) then
    slider:onChange(value);
  end
end

local function createSlider (name, parent, values, text, anchors)
  local slider = CreateFrame('Slider', name .. 'Slider', parent,
      'OptionsSliderTemplate');

  slider:SetPoint(anchors.anchor, anchors.parent, anchors.parentAnchor,
      anchors.xOffset, anchors.yOffset);
  slider:SetOrientation('HORIZONTAL');
  slider:SetMinMaxValues(values.min, values.max);
  slider:SetValueStep(1 / (10 ^ values.precision));
  slider:SetObeyStepOnDrag(true);

  _G[name .. 'SliderText']:SetText(text.label);
  _G[name .. 'SliderLow']:SetText(text.low);
  _G[name .. 'SliderHigh']:SetText(text.high);

  slider:SetScript('OnValueChanged', sliderOnValueChanged);
  slider.OnChange = setSliderOnChange;

  return slider;
end

local function createSliderWithEditBox (name, parent, values, text, anchors)
  local slider = createSlider(name, parent, values, text, anchors);
  local edit = createEditBox(name, slider);

  slider.edit = edit;

  return slider, edit;
end

function Slider:new (parent, name, anchorFrame, xOffset, yOffset, text, min,
                     max, lowText, highText, anchor, parentAnchor, precision)
  local this = {};

  setmetatable(this, Slider);

  precision = precision or 0;

  this.slider, this.edit = createSliderWithEditBox(name, parent, {
    precision = precision,
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

  this.precision = precision;

  return this;
end

function Slider:GetValue ()
  return addon.truncate(self.slider:GetValue(),
      addon.stepSizeToPrecision(self.slider:GetValueStep()));
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
