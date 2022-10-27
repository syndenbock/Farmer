local _, addon = ...;

local CreateFrame = _G.CreateFrame;
local CreateFromMixins = _G.CreateFromMixins;

local Button = addon.export('Class/Options/Button', {});

local function createButton (name, parent, text, anchors)
  local button = CreateFrame('Button', name .. 'Button', parent, 'UIPanelButtonTemplate');

  button:SetPoint(anchors.anchor, anchors.parent, anchors.parentAnchor,
      anchors.xOffset, anchors.yOffset);
  button:SetSize(165, 25);
  button:SetText(text);

  return button;
end

function Button:new (parent, name, anchorFrame, xOffset, yOffset, text, anchor,
                     parentAnchor, onClick)
  local this = CreateFromMixins(Button);

  this.button = createButton(name, parent, text, {
    anchor = anchor or 'TOPLEFT',
    parent = anchorFrame,
    parentAnchor = parentAnchor or 'BOTTOMLEFT',
    xOffset = xOffset,
    yOffset = yOffset,
  });

  if (onClick) then
    this:onClick(onClick);
  end

  return this;
end

function Button:onClick (callback)
  self.button:SetScript('OnClick', callback);
end
