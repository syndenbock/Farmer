local addonName, addon = ...;

local CreateFontStringPool = _G.CreateFontStringPool;
local CreateFrame = _G.CreateFrame;
local UIPARENT = _G.UIParent;
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT;

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

  anchor:SetSize(1, 1);
  anchor:SetPoint('CENTER', UIPARENT, 'CENTER', 0, 0);
  anchor:Show();

  this.anchor = anchor;
  this.pool = CreateFontStringPool(this.anchor, 'TOOLTIP', anchor);
  this.spacing = 0;

  return this;
end


function MessageFrame:AddMessage (text)
  local message = self.pool:Acquire();
  local tail = self.tail;

  if (tail) then
    tail.tail = message;
    message.head = tail;
  end

  self.tail = message;

  -- message:SetSize(200, 200);
  message:SetFont(STANDARD_TEXT_FONT, 18);
  message:SetText(text);
  message:Show();

  self:SetMessagePoints(message);

  return message;
end

function MessageFrame:RemoveMessage (fontString)
  assert(self.pool:IsActive(fontString), 'message is not currently displayed!');

  local head = fontString.head;
  local tail = fontString.tail;

  if (head) then
    head.tail = tail;
  end

  if (tail) then
    tail.head = head;
    self:SetMessagePoints(tail);
  else
    self.tail = head;
  end


  fontString:ClearAllPoints();
  fontString:Hide();
  self.pool:Release(fontString);
end

function MessageFrame:SetMessagePoints (fontString)
  fontString:ClearAllPoints();
  fontString:SetPoint('BOTTOM', fontString.head or self.anchor, 'TOP', 0 ,
      self.spacing);
end

do
  local f = MessageFrame:New();
  local m = {};

  addon.share('tests').msg = function (message)
    message = message or 'foo';
    m[message] = f:AddMessage(message);
  end

  addon.share('tests').rm = function (message)
    message = message or 'foo';
    f:RemoveMessage(m[message]);
  end

  addon.share('tests').foo = function ()
    print(f.tail:GetText());
  end
end
