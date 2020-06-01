local addonName, addon = ...;

local Factory = addon.OptionFactory;

local Label = {};

Label.__index = Label;

function Label:New (parent, anchorFrame, xOffset, yOffset, text, anchor, parentAnchor)
  local this = {};
  local label = parent:CreateFontString('FontString');

  setmetatable(this, Label);

  this.label = label;

  anchor = anchor or 'TOPLEFT';
  parentAnchor = parentAnchor or 'BOTTOMLEFT';

  --label:SetFont(addon.vars.font, 16, 'outline');
  --label:SetFont('ChatFontNormal', 16, 'outline');
  label:SetFont(STANDARD_TEXT_FONT, 14, 'outline');
  label:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset);
  label:SetText(text);

  return this;
end

Factory.Label = Label;
