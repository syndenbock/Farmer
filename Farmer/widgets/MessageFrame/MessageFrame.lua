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
  local head = fontString.head;
  local anchorPoint;
  local headAnchorPoint;

  fontString:ClearAllPoints();

  if (self.alignment == 'LEFT') then
    anchorPoint = 'LEFT';
  elseif (self.alignment == 'RIGHT') then
    anchorPoint = 'RIGHT';
  else
    anchorPoint = '';
  end

  if (self.direction == 'UP') then
    headAnchorPoint = 'TOP' .. anchorPoint;
    anchorPoint = 'BOTTOM' .. anchorPoint;
  else
    headAnchorPoint = 'BOTTOM' .. anchorPoint;
    anchorPoint = 'TOP' .. anchorPoint;
  end

  if (head) then
    fontString:SetPoint(anchorPoint, head, headAnchorPoint, 0, self.spacing);
  else
    fontString:SetPoint(anchorPoint, self.anchor, 'CENTER', 0, 0);
  end
end

function MessageFrame:SetSpacing (spacing)
  self.spacing = spacing;
  self:ForEachMessage(self.SetMessagePoints);
end

function MessageFrame:ForEachMessage (callback)
  local tail = self.tail;

  while (tail) do
    callback(self, tail);
    tail = tail.head;
  end
end

function MessageFrame:SetTextAlign (alignment)
  self.alignment = alignment;
  self:ForEachMessage(self.SetMessagePoints);
end

function MessageFrame:SetGrowDirection (direction)
  self.direction = direction;
  self:ForEachMessage(self.SetMessagePoints);
end

do
  local tests = addon.share('tests');

  local f = MessageFrame:New();
  local m = {};

  function tests.msg (message)
    message = message or 'foo';
    m[message] = f:AddMessage(message);
  end

  function tests.rm (message)
    message = message or 'foo';
    f:RemoveMessage(m[message]);
  end

  function tests.spacing (spacing)
    f:SetSpacing(tonumber(spacing));
  end

  function tests.align (alignment)
    f:SetTextAlign(alignment);
  end

  function tests.grow (direction)
    f:SetGrowDirection(direction);
  end
end
