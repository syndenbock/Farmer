local _, addon = ...;

local Factory = addon:share('OptionFactory');

local Slider = {};

Slider.__index = Slider;

function Slider:New (parent, name, anchorFrame, xOffset, yOffset, text, min, max, lowText, highText, anchor, parentAnchor, stepSize)
  stepSize = stepSize or 1;

  local this = {};
  local slider = CreateFrame('Slider', name .. 'Slider', parent, 'OptionsSliderTemplate');
  local edit = CreateFrame('EditBox', name .. 'EditBox', parent);

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

    if (this.onChange) then
      this.onChange(self, value);
    end
  end);

  anchor = slider;
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
  return self.slider:GetValue();
end

function Slider:SetValue (value)
  self.slider:SetValue(value);
end

function Slider:OnChange (callback)
  self.onChange = callback;
end

Factory.Slider = Slider;
