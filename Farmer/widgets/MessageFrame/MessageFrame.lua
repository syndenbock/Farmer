local addonName, addon = ...;

local CreateFontStringPool = _G.CreateFontStringPool;
local CreateFrame = _G.CreateFrame;

local MessageFrame = {};
local frameCount = 0;

MessageFrame.__index = MessageFrame;

addon.share('Widget').MessageFrame = MessageFrame;

local function generateFrameName ()
  local name = addonName .. 'MessageFrame' .. frameCount;

  frameCount = frameCount + 1;

  return name;
end

local function createAnchor ()
  return CreateFrame('Frame', generateFrameName());
end

function MessageFrame:New ()
  local this = {};
  local anchor = createAnchor();

  setmetatable(this, MessageFrame);

  anchor:SetSize(200, 200);
  anchor:SetPoint('CENTER', UIPARENT, 'CENTER', 0, 0);
  anchor:Show();

  this.anchor = anchor;
  this.pool = CreateFontStringPool(this.anchor, 'TOOLTIP', anchor);
  this.spacing = 0;

  return this;
end

function MessageFrame:AddMessage (text)
  local message = self.pool:Acquire();

  message:SetFont(STANDARD_TEXT_FONT, 18);
  -- message:SetSize(200, 200);
  message:Show();
  message:SetPoint('BOTTOM', self.tail or self.anchor, 'TOP', 0 , self.spacing);
  message:SetText(text);

  self.tail = message;
end

do
  local f;
  addon.share('tests').message = function (message)
    f = f or MessageFrame:New();
    f:AddMessage(message or 'foo');
  end
end
