local _, addon = ...;

local CreateFrame = _G.CreateFrame;

local Factory = addon:share('OptionFactory');
local Button = {};

Factory.Button = Button;

Button.__index = Button;

function Button:New (parent, name, anchorFrame, xOffset, yOffset, text, anchor,
                     parentAnchor, onClick)
  local this = {};
  local button = CreateFrame('Button', name .. 'Button', parent,
      'OptionsButtonTemplate');

  setmetatable(this, Button);

  this.button = button;

  anchor = anchor or 'TOPLEFT';
  parentAnchor = parentAnchor or 'BOTTOMLEFT';

  button:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset);
  button:SetSize(150, 25);
  button:SetText(text);

  if (onClick) then
    this:onClick(onClick);
  end

  return this;
end

function Button:onClick (callback)
  self.button:SetScript('OnClick', callback);
end
