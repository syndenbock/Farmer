local _, addon = ...;

local CreateFrame = _G.CreateFrame;

local Factory = addon:share('OptionFactory');

local CheckBox = {};

Factory.CheckBox = CheckBox;

CheckBox.__index = CheckBox;

local function doNothing () end

local function createCheckBox (name, parent, text, anchors)
  local checkBox = CreateFrame('CheckButton', name .. 'CheckButton', parent,
      'OptionsCheckButtonTemplate');

  -- Blizzard really knows how to write APIs. Not.
  _G[name .. 'CheckButtonText']:SetText(text);
  _G[name .. 'CheckButtonText']:SetJustifyH('LEFT');

  checkBox:SetPoint(anchors.anchor, anchors.parent, anchors.parentAnchor,
      anchors.xOffset, anchors.yOffset);

  -- Blizzard broke something in the BfA beta, so we have to fix it
  checkBox.SetValue = doNothing;

  return checkBox;
end

function CheckBox:new (parent, name, anchorFrame, xOffset, yOffset, text,
                       anchor, parentAnchor)
  local this = {};

  setmetatable(this, CheckBox);

  this.checkBox = createCheckBox(name, parent, text, {
    anchor = anchor or 'TOPLEFT',
    parent = anchorFrame,
    parentAnchor = parentAnchor or 'BOTTOMLEFT',
    xOffset = xOffset,
    yOffset = yOffset,
  });

  return this;
end

function CheckBox:GetValue ()
  return self.checkBox:GetChecked();
end

function CheckBox:SetValue (checked)
  return self.checkBox:SetChecked(checked);
end
