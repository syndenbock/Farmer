local addonName, addon = ...;

local CreateFontStringPool = _G.CreateFontStringPool;
local CreateFrame = _G.CreateFrame;
local C_Timer = _G.C_Timer;
local UIPARENT = _G.UIParent;
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT;

local Set = addon.Class.Set;

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
  local anchor = CreateFrame('Frame', generateFrameName());

  anchor:SetSize(1, 1);
  anchor:SetPoint('CENTER', UIPARENT, 'CENTER', 0, 0);
  anchor:Show();

  return anchor;
end

function MessageFrame:New ()
  local this = {};
  local anchor = createAnchor();

  setmetatable(this, MessageFrame);

  this.updates = Set:new();
  this.anchor = anchor;
  this.pool = CreateFontStringPool(this.anchor, 'TOOLTIP', anchor);
  this.spacing = 0;
  this.fadeDuration = 2;
  this.visibleTime = 3;
  this.font = STANDARD_TEXT_FONT;
  this.fontSize = 18;
  this.fontFlags = 'OUTLINE';

  return this;
end

function MessageFrame:AddAlphaHandler (fontString)
  local this = self;

  if (self.updates:getItemCount() == 0) then
    self.anchor:SetScript('OnUpdate', function (_, elapsed)
      this:HandleUpdate(elapsed);
    end);
  end

  self.updates:addItem(fontString);
end

function MessageFrame:HandleUpdate (elapsed)
  self.updates:forEach(function (fontString)
    self:HandleMessageFade(fontString, elapsed);
  end);
end

function MessageFrame:RemoveAlphaHandler (fontString)
  self.updates:removeItem(fontString);
  if (self.updates:getItemCount() == 0) then
    self.anchor:SetScript('OnUpdate', nil);
  end
end

function MessageFrame:AddMessage (text, r, g, b, a)
  local message = self.pool:Acquire();
  local visibleTime = self.visibleTime or 0;

  self:SetFontStringFont(message);
  message:SetTextColor(r or 1, g or 1, b or 1, a or 1);
  message:SetText(text);
  message:Show();

  self:InsertMessage(message);

  if (visibleTime > 0) then
    C_Timer.After(visibleTime, function ()
      self:FadeMessage(message);
    end);
  else
    self:FadeMessage(message);
  end

  return message;
end

function MessageFrame:InsertMessage (fontString)
  --[[ TODO build support for insert modes ]]
  self:PrependMessage(fontString);
end

function MessageFrame:PrependMessage (fontString)
  local head = self.head;

  self:AttachFontString(fontString, head);

  self.head = fontString;
  self.tail = self.tail or fontString;

  self:SetMessagePoints(fontString);
  self:SetMessagePoints(head);
end

function MessageFrame:AttachFontString (head, tail)
  if (head) then
    head.tail = tail;
  end

  if (tail) then
    tail.head = head;
  end
end

function MessageFrame:RemoveMessage (fontString)
  assert(self.pool:IsActive(fontString), 'message is not currently displayed!');

  local head = fontString.head;
  local tail = fontString.tail;

  self:AttachFontString(head, tail);

  if (self.head == fontString) then
    self.head = tail;
  end

  if (self.tail == fontString) then
    self.tail = head;
  end

  self:SetMessagePoints(tail);
  fontString:ClearAllPoints();
  fontString:Hide();
  fontString.head = nil;
  fontString.tail = nil;

  self.pool:Release(fontString);
end

function MessageFrame:SetMessagePoints (fontString)
  if (not fontString) then return end

  local head = fontString.head;
  local anchorPoint;
  local headAnchorPoint;

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

  fontString:ClearAllPoints();

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

function MessageFrame:SetFont (font, fontSize, fontFlags)
  self.font = font;
  self.fontSize = fontSize;
  self.fontFlags = fontFlags;

  self:ForEachMessage(self.SetFontStringFont);
end

function MessageFrame:SetFontStringFont (fontString)
  fontString:SetFont(self.font, self.fontSize, self.fontFlags);
end

function MessageFrame:SetFadeDuration (duration)
  self.fadeDuration = duration;
end

function MessageFrame:GetFadeDuration ()
  return self.fadeDuration;
end

function MessageFrame:SetVisibleTime (duration)
  self.visibleTime = duration;
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

function MessageFrame:FadeMessage (fontString)
  assert(self.pool:IsActive(fontString), 'message is not currently displayed!');
  assert(fontString.isFading ~= true, 'message is already fading');

  local fadeDuration = self.fadeDuration;

  if (not fadeDuration or fadeDuration <= 0) then
    self:RemoveMessage(fontString);
    return;
  end

  fontString.isFading = true;
  fontString.fadeSpeed = fontString:GetAlpha() / fadeDuration;

  self:AddAlphaHandler(fontString);
end

function MessageFrame:HandleMessageFade (fontString, elapsed)
  assert(fontString.isFading == true, 'message is not fading!');

  local alpha = fontString:GetAlpha() - fontString.fadeSpeed * elapsed, 0;

  if (alpha > 0) then
    fontString:SetAlpha(alpha);
  else
    self:RemoveMessage(fontString);
    fontString.isFading = nil;
    fontString.fadeSpeed = nil;
    fontString:SetAlpha(1);
    self:RemoveAlphaHandler(fontString);
  end
end

function MessageFrame:ClearAllPoints ()
  -- self.anchor:ClearAllPoints();
end

function MessageFrame:SetPoint (...)
  -- self.anchor:SetPoint(...);
end

function MessageFrame:GetEffectiveScale ()
  return self.anchor:GetEffectiveScale();
end

function MessageFrame:SetShadowColor () end
function MessageFrame:SetShadowOffset () end

MessageFrame.SetJustifyH = MessageFrame.SetTextAlign;
MessageFrame.SetInsertMode = MessageFrame.SetGrowDirection;
MessageFrame.SetTimeVisible = MessageFrame.SetVisibleTime;

do
  local tests = addon.share('tests');

  local f = MessageFrame:New();
  local m = {};

  function tests.msg (message)
    message = message or 'foo';
    if (m[message]) then
      f:RemoveMessage(m[message]);
    end
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

  function tests.fade (message, time)
    message = message or 'foo';
    f:SetFadeDuration(tonumber(time or 1));

    if (m[message]) then
      f:RemoveMessage(message);
    end

    tests.msg(message);
  end

  function tests.visible (message, time)
    message = message or 'foo';
    f:SetVisibleTime(tonumber(time or 1));

    if (m[message]) then
      f:RemoveMessage(message);
    end

    tests.msg(message);
  end
end
