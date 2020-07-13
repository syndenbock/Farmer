local _, addon = ...;

local CreateFrame = _G.CreateFrame;

local Factory = addon:share('OptionFactory');

local CheckBox = {};

Factory.CheckBox = CheckBox;

CheckBox.__index = CheckBox;

function CheckBox:New (parent, name, anchorFrame, xOffset, yOffset, text,
                       anchor, parentAnchor)
  local this = {};
  local checkBox = CreateFrame('CheckButton', name .. 'CheckButton', parent,
      'OptionsCheckButtonTemplate')

  setmetatable(this, CheckBox);

  this.checkBox = checkBox;

  anchor = anchor or 'TOPLEFT';
  parentAnchor = parentAnchor or 'BOTTOMLEFT';

  checkBox:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset);

  -- Blizzard really knows how to write APIs. Not.
  _G[name .. 'CheckButtonText']:SetText(text);
  _G[name .. 'CheckButtonText']:SetJustifyH('LEFT');

  -- Blizzard broke something in the BfA beta, so we have to fix it
  checkBox.SetValue = function () end

  return this;
end

function CheckBox:GetValue ()
  return self.checkBox:GetChecked();
end

function CheckBox:SetValue (checked)
  return self.checkBox:SetChecked(checked);
end
