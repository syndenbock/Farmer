local _, addon = ...;

local CreateFontStringPool = _G.CreateFontStringPool;
local CreateFrame = _G.CreateFrame;
local UIPARENT = _G.UIParent;
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT;

local transformFrameAnchorsToCenter = addon.transformFrameAnchorsToCenter;

local ANCHOR_NONE = '';
local ANCHOR_CENTER = 'CENTER';
local ANCHOR_LEFT = 'LEFT';
local ANCHOR_RIGHT = 'RIGHT';
local ANCHOR_TOP = 'TOP';
local ANCHOR_BOTTOM = 'BOTTOM';
local GROW_DIRECTION_UP = 'UP';
local GROW_DIRECTION_DOWN = 'DOWN';
local INSERTMODE_PREPEND = 'PREPEND';
local INSERTMODE_APPEND = 'APPEND';
local ALIGNMENT_LEFT = 'LEFT';
local ALIGNMENT_CENTER = 'CENTER';
local ALIGNMENT_RIGHT = 'RIGHT';

local MessageFrame = {
  GROW_DIRECTION_UP = GROW_DIRECTION_UP,
  GROW_DIRECTION_DOWN = GROW_DIRECTION_DOWN,
  ALIGNMENT_LEFT = ALIGNMENT_LEFT,
  ALIGNMENT_CENTER = ALIGNMENT_CENTER,
  ALIGNMENT_RIGHT = ALIGNMENT_RIGHT,
  INSERTMODE_PREPEND = INSERTMODE_PREPEND,
  INSERTMODE_APPEND = INSERTMODE_APPEND,
};

addon.share('Widget').MessageFrame = MessageFrame;

local function proxyMethod (object, proxy, methodName, method)
  local function callback (_, ...)
    return method(proxy, ...);
  end

  object[methodName] = callback;

  return callback;
end

local function updateOptions (defaults, options)
  for key, value in pairs(options) do
    if (defaults[key] ~= nil) then
      defaults[key] = value;
    else
      -- print('unknown option:', key .. '=' .. value);
    end
  end
end

local function transformOptions (options)
  if (type(options) == 'string') then
    return {
      name = options,
    };
  else
    return options or {};
  end
end

local function createAnchor (name, frameStrata, frameLevel)
  local anchor = CreateFrame('Frame', name, UIPARENT);

  anchor:SetSize(2, 2);
  anchor:SetPoint(ANCHOR_CENTER, UIPARENT, ANCHOR_CENTER, 0, 0);
  anchor:SetFrameStrata(frameStrata);
  anchor:SetFrameLevel(frameLevel);
  anchor:Show();

  return anchor;
end

local function createBase (options)
  local this = {};

  options = transformOptions(options);

  --[[ options ]]
  this.name = options.name;
  this.frameStrata = 'TOOLTIP';
  this.frameLevel = 0;
  this.spacing = 0;
  this.fadeDuration = 2;
  this.visibleTime = 3;
  this.font = STANDARD_TEXT_FONT;
  this.fontSize = 18;
  this.fontFlags = 'OUTLINE';
  this.fading = true;
  this.insertMode = INSERTMODE_PREPEND;
  this.shadowColors = {r = 0, g = 0, b = 0, a = 1};
  this.shadowOffset = {x = 0, y = 0};

  updateOptions(this, options);

  return this;
end

--##############################################################################
-- public methods
--##############################################################################

function MessageFrame:New (options)
  local this = createBase(options);
  local anchor = createAnchor(this.name, this.frameStrata, this.frameLevel);

  setmetatable(this, {
    __index = function (_, key)
      local value = MessageFrame[key];

      if (value ~= nil) then
        return value;
      end

      value = anchor[key];

      if (type(value) == 'function') then
        return proxyMethod(this, anchor, key, value);
      end

      return value;
    end
  });

  this.anchor = anchor;
  this.pool = CreateFontStringPool(anchor, this.frameStrata,
      this.frameLevel);

  return this;
end

function MessageFrame:Move (message, callback)
  local fontString = self:CreateAnchorFontString(message);

  transformFrameAnchorsToCenter(self.anchor);
  self.anchor:SetSize(200, 200);
  self:StartMoving(fontString, callback);
end

function MessageFrame:StartMoving (fontString, callback)
  if (self.isMoving) then return end

  local anchor = self.anchor;

  self.isMoving = true;

  anchor:RegisterForDrag('LeftButton');
  anchor:EnableMouse(true);
  anchor:SetMovable(true);

  anchor:SetScript('OnDragStart', function ()
    if (anchor:IsMovable() == true) then
      anchor:StartMoving();
    end
  end);

  anchor:SetScript('OnReceiveDrag', function ()
    self.isMoving = false;
    self:StartFontStringAnimation(fontString);
    self:StopMoving();

    transformFrameAnchorsToCenter(anchor);
    anchor:SetSize(2, 2);

    if (callback) then
      callback();
    end
  end);
end

function MessageFrame:StopMoving ()
  local anchor = self.anchor;

  anchor:RegisterForDrag();
  anchor:EnableMouse(false);
  anchor:SetMovable(false);
  anchor:StopMovingOrSizing();
  anchor:SetScript('OnDragStart', nil);
  anchor:SetScript('OnReceiveDrag', nil);
end

function MessageFrame:AddMessage (text, r, g, b, a)
  local fontString = self:CreateFontString(text, r, g, b, a);

  self:InsertMessage(fontString);

  if (self.fading) then
    self:StartFontStringAnimation(fontString);
  end

  return fontString;
end

function MessageFrame:AddAnchorMessage (text, r, g, b, a)
  self:StartFontStringAnimation(self:CreateAnchorFontString(text, r, g, b, a));
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

  self:SetFontStringPointsIfExists(tail);

  self.pool:Release(fontString);
  self:ResetFontString(fontString);
end

function MessageFrame:Clear ()
  self:ForEachDisplayedMessage(self.RemoveMessage);
end

function MessageFrame:SetFading (fading)
  --[[ when toggling from not fading to fading, current permanent messages
  will fade ]]
  if (not self.fading and fading) then
    self:ForEachDisplayedMessage(self.StartFontStringAnimation);
  end

  self.fading = fading;
end

function MessageFrame:GetFading ()
  return self.fading;
end

function MessageFrame:SetSpacing (spacing)
  self.spacing = spacing;
  --[[ Calls of GetPoint are so expensive that recalculating all anchors is
    faster than only updating the y-offset ]]
  self:ForEachDisplayedMessage(self.SetFontStringPoints);
end

function MessageFrame:SetFrameStrata (frameStrata)
  self.frameStrata = frameStrata;
  self.anchor:SetFrameStrata(frameStrata);
  self.pool.layer = frameStrata;

  self:ForEachDisplayedMessage(self.SetFontStringFrameStrata);
end

function MessageFrame:GetFrameStrata ()
  return self.frameStrata;
end

function MessageFrame:SetFrameLevel (frameLevel)
  self.frameLevel = frameLevel;
  self.anchor:SetFrameLevel(frameLevel);
  self.pool.subLayer = frameLevel;

  self:ForEachDisplayedMessage(self.SetFontStringFrameLevel)
end

function MessageFrame:GetFrameLevel ()
  return self.frameLevel;
end

function MessageFrame:SetFont (font, fontSize, fontFlags)
  self.font = font;
  self.fontSize = fontSize;
  self.fontFlags = fontFlags;

  self:ForEachDisplayedMessage(self.SetFontStringFont);
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

function MessageFrame:GetVisibleTime ()
  return self.visibleTime;
end

function MessageFrame:SetTextAlign (alignment)
  self.alignment = alignment;
  self:ForEachMessage(self.SetFontStringPoints);
end

function MessageFrame:GetTextAlign ()
  return self.alignment;
end

function MessageFrame:SetGrowDirection (direction)
  self.direction = direction;
  self:ForEachDisplayedMessage(self.SetFontStringPoints);
end

function MessageFrame:GetGrowDirection ()
  return self.direction;
end

function MessageFrame:SetShadowColor (r, g, b, a)
  local colors = self.shadowColors;

  colors.r = r or colors.r;
  colors.g = g or colors.g;
  colors.b = b or colors.b;
  colors.a = a or colors.a;

  self:ForEachDisplayedMessage(self.SetFontStringShadowColor);
end

function MessageFrame:SetInsertMode (insertMode)
  if ((self.insertMode == INSERTMODE_PREPEND) ~=
      (insertMode == INSERTMODE_PREPEND)) then
    self:ForEachDisplayedMessage(self.InvertFontStringDirection);
  end

  self.insertMode = insertMode;
end

function MessageFrame:GetInsertMode ()
  return self.insertMode;
end

function MessageFrame:GetShadowColor ()
  local colors = self.shadowColors;

  return colors.r, colors.g, colors.b, colors.a;
end

function MessageFrame:SetShadowOffset (x, y)
  local offset = self.shadowOffset;

  offset.x = x or offset.x;
  offset.y = y or offset.y;

  self:ForEachDisplayedMessage(self.SetFontStringShadowOffset);
end

function MessageFrame:GetShadowOffset ()
  return self.shadowOffset.x, self.shadowOffset.y;
end

--[[ aliases for default frame methods ]]
MessageFrame.SetJustifyH = MessageFrame.SetTextAlign;
MessageFrame.GetJustifyH = MessageFrame.GetTextAlign;
MessageFrame.SetTimeVisible = MessageFrame.SetVisibleTime;
MessageFrame.GetTimeVisible = MessageFrame.GetVisibleTime;

--##############################################################################
-- private methods
--##############################################################################

function MessageFrame:CreateFontString (text, r, g, b, a)
  local fontString = self.pool:Acquire();

  fontString:SetParent(self.anchor);
  self:SetFontStringFont(fontString);
  self:SetFontStringShadowColor(fontString);
  self:SetFontStringShadowOffset(fontString);
  fontString:SetTextColor(r or 1, g or 1, b or 1, a or 1);
  fontString:SetText(text);
  fontString:Show();

  return fontString;
end

function MessageFrame:CreateAnchorFontString (message, r, g, b, a)
  local fontString = self:CreateFontString(message, r, g, b, a);

  fontString:SetParent(self.anchor);
  self:SetFontStringPoints(fontString);

  return fontString;
end

function MessageFrame:ResetFontString (fontString)
  --[[ no need to reset default attributes, as the pool resetter automatically
    does this ]]
  fontString.head = nil;
  fontString.tail = nil;
  fontString.isFading = nil;
  fontString.fadeSpeed = nil;

  if (fontString.animationGroup) then
    fontString.animationGroup:Stop();
  end
end

function MessageFrame:InsertMessage (fontString)
  if (self.insertMode == INSERTMODE_PREPEND) then
    self:PrependMessage(fontString);
  else
    self:AppendMessage(fontString);
  end
end

function MessageFrame:AppendMessage (fontString)
  self:AttachFontString(self.tail, fontString);

  self.head = self.head or fontString;
  self.tail = fontString;

  self:SetFontStringPoints(fontString);
end

function MessageFrame:PrependMessage (fontString)
  local head = self.head;

  self:AttachFontString(fontString, head);

  self.head = fontString;
  self.tail = self.tail or fontString;

  self:SetFontStringPoints(fontString);
  self:SetFontStringPointsIfExists(head);
end

--******************************************************************************
-- message positioning methods
--******************************************************************************

function MessageFrame:AttachFontString (head, tail)
  if (head) then
    head.tail = tail;
  end

  if (tail) then
    tail.head = head;
  end
end

function MessageFrame:SetFontStringPoints (fontString)
  local head = fontString.head;
  local alignmentAnchor;
  local anchorPoint;

  if (self.alignment == ALIGNMENT_LEFT) then
    alignmentAnchor = ANCHOR_LEFT;
  elseif (self.alignment == ALIGNMENT_RIGHT) then
    alignmentAnchor = ANCHOR_RIGHT;
  else
    alignmentAnchor = ANCHOR_NONE;
  end

  if (self.direction == GROW_DIRECTION_UP) then
    anchorPoint = ANCHOR_BOTTOM .. alignmentAnchor;
  else
    anchorPoint = ANCHOR_TOP .. alignmentAnchor;
  end

  fontString:ClearAllPoints();

  if (head) then
    local headAnchorPoint;
    local yOffset;

    if (self.direction == GROW_DIRECTION_UP) then
      yOffset = self.spacing;
      headAnchorPoint = ANCHOR_TOP .. alignmentAnchor;
    else
      yOffset = -self.spacing;
      headAnchorPoint = ANCHOR_BOTTOM .. alignmentAnchor;
    end

    fontString:SetPoint(anchorPoint, head, headAnchorPoint, 0, yOffset);
  else
    fontString:SetPoint(anchorPoint, self.anchor, ANCHOR_CENTER, 0, 0);
  end
end

function MessageFrame:SetFontStringPointsIfExists (fontString)
  if (not fontString) then return end

  self:SetFontStringPoints(fontString);
end

function MessageFrame:InvertFontStringDirection (fontString)
  --[[ Only use this function when applying it to all fontStrings in the chain.
    Otherwise, this will cause a loop in the chain. ]]
  local head = fontString.head;

  fontString.head = fontString.tail;
  fontString.tail = head;

  self:SetFontStringPoints(fontString);
end

--******************************************************************************
-- fontString visibility methods
--******************************************************************************

function MessageFrame:StartFontStringAnimation (fontString)
  if (self.visibleTime <= 0 and self.fadeDuration <= 0) then
    self:RemoveMessage(fontString);
    return;
  end

  self:CreateFontStringAnimation(fontString);
  fontString.animationGroup:Play();
end

function MessageFrame:CreateFontStringAnimation (fontString)
  local animation = fontString.animation;

  if (not fontString.animationGroup) then
    fontString.animationGroup = fontString:CreateAnimationGroup();
  end

  if (not animation) then
    animation = fontString.animationGroup:CreateAnimation('Alpha');

    animation:SetToAlpha(0);
    animation:SetOrder(1);
    animation.parent = self;
    animation.fontString = fontString;

    animation:SetScript('OnFinished', self.OnFontStringAnimationFinished);
    fontString.animation = animation;
  end

  animation:SetStartDelay(self.visibleTime);
  animation:SetDuration(self.fadeDuration);
  animation:SetFromAlpha(fontString:GetAlpha());
end

function MessageFrame.OnFontStringAnimationFinished (animation)
  animation.parent:RemoveMessage(animation.fontString);
end

--******************************************************************************
-- fontString attribute setters
--******************************************************************************

function MessageFrame:SetFontStringFont (fontString)
  fontString:SetFont(self.font, self.fontSize, self.fontFlags);
end

function MessageFrame:SetFontStringShadowColor (fontString)
  local colors = self.shadowColors;
  fontString:SetShadowColor(colors.r, colors.g, colors.b, colors.a);
end

function MessageFrame:SetFontStringShadowOffset (fontString)
  fontString:SetShadowOffset(self.shadowOffset.x, self.shadowOffset.y);
end

function MessageFrame:SetFontStringFrameStrata (fontString)
  fontString:SetFrameStrata(self.frameStrata);
end

function MessageFrame:SetFontStringFrameLevel (fontString)
  fontString:SetFrameLevel(self.frameLevel);
end

--******************************************************************************
-- helper methods
--******************************************************************************

function MessageFrame:ForEachMessage (callback, ...)
  for fontString in self.pool:EnumerateActive() do
    callback(self, fontString, ...);
  end
end

function MessageFrame:ForEachDisplayedMessage (callback, ...)
  local tail = self.tail;

  while (tail) do
    local next = tail.head;
    callback(self, tail, ...);
    tail = next;
  end
end
