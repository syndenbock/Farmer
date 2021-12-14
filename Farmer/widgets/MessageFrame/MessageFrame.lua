local _, addon = ...;

local max = _G.max;

local CreateFramePool = _G.CreateFramePool;
local CreateFromMixins = _G.CreateFromMixins;
local CreateFrame = _G.CreateFrame;
local UIPARENT = _G.UIParent;
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT;

local transformFrameAnchorsToCenter = addon.transformFrameAnchorsToCenter;

local ON_MOUSE_DOWN = 'OnMouseDown';
local ON_MOUSE_UP = 'OnMouseUp';

local FRAME = 'frame';

local LAYER_ARTWORK = 'ARTWORK';

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

local ICON_OFFSET = 3;

local DEFAULT_OPTIONS = {
  frameStrata = 'TOOLTIP',
  frameLevel = 0,
  spacing = 0,
  fadeDuration = 1,
  visibleTime = 3,
  font = STANDARD_TEXT_FONT,
  fontSize = 18,
  fontFlags = 'OUTLINE',
  fading = true,
  iconScale = 1,
  insertMode = INSERTMODE_PREPEND,
  shadowColors = {r = 0, g = 0, b = 0, a = 1},
  shadowOffset = {x = 0, y = 0},
};

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

local function transformOptions (options)
  if (type(options) == 'string') then
    return {
      name = options,
    };
  else
    return options or {};
  end
end

local function readOptions (self, options)
  options = transformOptions(options);
  addon.readOptions(DEFAULT_OPTIONS, options, self);
  addon.name = options.name;
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

--##############################################################################
-- public methods
--##############################################################################

function MessageFrame:New (options)
  local this = CreateFromMixins(MessageFrame);

  readOptions(this, options);

  this.anchor = createAnchor(this.name, this.frameStrata, this.frameLevel);

  -- these are only needed for initialization
  this.frameStrata = nil;
  this.frameLevel = nil;

  this.framePool = CreateFramePool(FRAME, this.anchor, nil, this.ResetMessage, false);
  this.framePool:SetResetDisallowedIfNew(true);
  this:UpdateSizes();

  return this;
end

function MessageFrame:Move (icon, text, callback)
  local message = self:CreateAnchorMessage(icon, text);

  transformFrameAnchorsToCenter(self.anchor);
  self.anchor:SetSize(200, 200);
  self:StartMoving(message, callback);
end

function MessageFrame:StartMoving (message, callback)
  if (self.isMoving) then return end

  local anchor = self.anchor;

  self.isMoving = true;

  anchor:EnableMouse(true);
  anchor:SetMovable(true);

  anchor:SetScript(ON_MOUSE_DOWN, function ()
    if (anchor:IsMovable() == true) then
      anchor:StartMoving();
    end
  end);

  anchor:SetScript(ON_MOUSE_UP, function ()
    self.isMoving = false;
    self:StartMessageAnimation(message);
    self:StopMoving();

    transformFrameAnchorsToCenter(anchor);
    anchor:SetSize(20, 20);

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
  anchor:SetScript(ON_MOUSE_DOWN, nil);
  anchor:SetScript(ON_MOUSE_UP, nil);
end

function MessageFrame:AddMessage (text, r, g, b, a)
  return self:AddIconMessage(nil, text, r, g, b, a);
end

function MessageFrame:AddIconMessage (icon, text, r, g, b, a)
  local message = self:CreateMessage(icon, text, r, g, b, a);

  self:InsertMessage(message);

  if (self.fading) then
    self:StartMessageAnimation(message);
  end

  return message;
end

function MessageFrame:AddAnchorMessage (icon, text, r, g, b, a)
  self:StartMessageAnimation(self:CreateAnchorMessage(icon, r, g, b, a));
end

function MessageFrame:RemoveMessage (message)
  assert(self.framePool:IsActive(message), 'message is not currently displayed!');

  local head = message.head;
  local tail = message.tail;

  self:AttachMessage(head, tail);

  if (self.head == message) then
    self.head = tail;
  end

  if (self.tail == message) then
    self.tail = head;
  end

  self:SetMessagePointsIfExists(tail);
  self.framePool:Release(message);
end

function MessageFrame:Clear ()
  self:ForEachActiveMessage(self.RemoveMessage);
end

function MessageFrame:SetFading (fading)
  --[[ when toggling from not fading to fading, current permanent messages
  will fade ]]
  if (not self.fading and fading) then
    self:ForEachActiveMessage(self.StartMessageAnimation);
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
  self:ForEachActiveMessage(self.SetMessagePoints);
end

function MessageFrame:SetFont (font, fontSize, fontFlags)
  self.font = font;
  self.fontSize = fontSize;
  self.fontFlags = fontFlags;

  self:ForEachMessage(self.SetMessageFont);
  self:UpdateSizes();
end

function MessageFrame:SetIconScale (scale)
  self.iconScale = scale;
  self:UpdateSizes();
end

function MessageFrame:UpdateSizes ()
  self.iconSize = self.fontSize * self.iconScale;
  self:ForEachActiveMessage(self.ResizeMessage);
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
  self:ForEachMessage(self.SetMessageTextAlign, alignment);
  self:ForEachActiveMessage(self.SetMessagePoints);
end

function MessageFrame:GetTextAlign ()
  return self.alignment;
end

function MessageFrame:SetGrowDirection (direction)
  self.direction = direction;
  self:ForEachActiveMessage(self.SetMessagePoints);
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

  self:ForEachActiveMessage(self.SetMessageShadowColor);
end

function MessageFrame:SetInsertMode (insertMode)
  if ((self.insertMode == INSERTMODE_PREPEND) ~=
      (insertMode == INSERTMODE_PREPEND)) then
    self:ForEachActiveMessage(self.InvertMessageDirection);
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

  self:ForEachActiveMessage(self.SetMessageShadowOffset);
end

function MessageFrame:GetShadowOffset ()
  return self.shadowOffset.x, self.shadowOffset.y;
end

--##############################################################################
-- anchor proxy methods
--##############################################################################

local function proxyAnchorMethod (methodName)
  MessageFrame[methodName] = function (self, ...)
    return self.anchor[methodName](self.anchor, ...);
  end
end

proxyAnchorMethod('ClearAllPoints');
proxyAnchorMethod('SetPoint');
proxyAnchorMethod('GetCenter');
proxyAnchorMethod('SetFrameStrata');
proxyAnchorMethod('GetFrameStrata');
proxyAnchorMethod('SetFrameLevel');
proxyAnchorMethod('GetFrameLevel');
proxyAnchorMethod('GetScale');
proxyAnchorMethod('GetEffectiveScale');

--[[ aliases for default frame methods ]]
MessageFrame.SetJustifyH = MessageFrame.SetTextAlign;
MessageFrame.GetJustifyH = MessageFrame.GetTextAlign;
MessageFrame.SetTimeVisible = MessageFrame.SetVisibleTime;
MessageFrame.GetTimeVisible = MessageFrame.GetVisibleTime;

--##############################################################################
-- private methods
--##############################################################################

function MessageFrame:CreateMessage (icon, text, r, g, b, a)
  local message = self.framePool:Acquire();

  if (message.fontString == nil) then
    message.fontString = self:CreateFontString(message);
  end

  message.fontString:SetTextColor(r or 1, g or 1, b or 1, a or 1);
  message.fontString:SetText(text);

  if (message.iconFrame == nil) then
    message.iconFrame = self:CreateIconFrame(message);
  end

  self:ResizeMessage(message);
  message:Show();

  if (icon) then
    message.iconFrame:SetTexture(icon);
    message.iconFrame:Show();
  else
    message.iconFrame:Hide();
  end

  return message;
end

function MessageFrame:CreateFontString (parent)
  local fontString = parent:CreateFontString();

  fontString:SetParent(parent);
  fontString:SetPoint(ANCHOR_RIGHT, parent, ANCHOR_RIGHT, 0, 0);
  fontString:Show();

  self:SetFontStringFont(fontString);
  self:SetFontStringTextAlign(fontString, self.alignment);
  self:SetFontStringShadowColor(fontString);
  self:SetFontStringShadowOffset(fontString);

  return fontString;
end

function MessageFrame:CreateIconFrame (parent)
  local iconFrame = parent:CreateTexture();

  iconFrame:SetParent(parent);
  iconFrame:SetPoint(ANCHOR_LEFT, parent, ANCHOR_LEFT, 0, 0);
  iconFrame:SetTexCoord(0.1, 0.9, 0.1, 0.9);

  return iconFrame;
end

function MessageFrame:ResizeMessage (message)
  local textWidth, textHeight = message.fontString:GetSize();
  local iconSize = self.iconSize;

  message.iconFrame:SetSize(iconSize, iconSize);
  message:SetSize(iconSize + ICON_OFFSET + textWidth, max(iconSize, textHeight));
end

function MessageFrame:CreateAnchorMessage (icon, text, r, g, b, a)
  -- Setting an anchor text doesn't properly work yet as the message itself
  -- cannot be dragged which causes parts of the message not being able to
  -- clicked if they don't overlap the moving anchor.
  local message = self:CreateMessage(icon, nil, r, g, b, a);

  self:SetMessagePoints(message);

  return message;
end

function MessageFrame:ResetMessage (message)
  message:Hide();
  message.head = nil;
  message.tail = nil;
  message.isFading = nil;

  if (message.animationGroup) then
    message.animationGroup:Stop();
  end

  if (message.animation) then
    message.animation:Stop();
  end
end

function MessageFrame:InsertMessage (message)
  if (self.insertMode == INSERTMODE_PREPEND) then
    self:PrependMessage(message);
  else
    self:AppendMessage(message);
  end
end

function MessageFrame:AppendMessage (message)
  self:AttachMessage(self.tail, message);

  self.head = self.head or message;
  self.tail = message;

  self:SetMessagePoints(message);
end

function MessageFrame:PrependMessage (message)
  local head = self.head;

  self:AttachMessage(message, head);

  self.head = message;
  self.tail = self.tail or message;

  self:SetMessagePoints(message);
  self:SetMessagePointsIfExists(head);
end

--******************************************************************************
-- message positioning methods
--******************************************************************************

function MessageFrame:AttachMessage (head, tail)
  if (head) then
    head.tail = tail;
  end

  if (tail) then
    tail.head = head;
  end
end

function MessageFrame:SetMessagePoints (message)
  local head = message.head;
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

  message:ClearAllPoints();

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

    message:SetPoint(anchorPoint, head, headAnchorPoint, 0, yOffset);
  else
    message:SetPoint(anchorPoint, self.anchor, ANCHOR_CENTER, 0, 0);
  end
end

function MessageFrame:SetMessagePointsIfExists (message)
  if (not message) then return end

  self:SetMessagePoints(message);
end

function MessageFrame:InvertMessageDirection (message)
  --[[ Only use this function when applying it to all messages in the chain.
    Otherwise, this will cause a loop in the chain. ]]
  local head = message.head;

  message.head = message.tail;
  message.tail = head;

  self:SetMessagePoints(message);
end

--******************************************************************************
-- message visibility methods
--******************************************************************************

function MessageFrame:StartMessageAnimation (message)
  if (self.visibleTime <= 0 and self.fadeDuration <= 0) then
    self:RemoveMessage(message);
    return;
  end

  self:CreateMessageAnimation(message);
  message.animationGroup:Play();
end

function MessageFrame:CreateMessageAnimation (message)
  local animation = message.animation;

  if (not message.animationGroup) then
    message.animationGroup = message:CreateAnimationGroup();
  end

  if (not animation) then
    animation = message.animationGroup:CreateAnimation('Alpha');

    animation:SetToAlpha(0);
    animation:SetOrder(1);
    animation.parent = self;
    animation.message = message;

    animation:SetScript('OnFinished', self.OnMessageAnimationFinished);
    message.animation = animation;
  end

  animation:SetStartDelay(self.visibleTime);
  animation:SetDuration(self.fadeDuration);
  animation:SetFromAlpha(message:GetAlpha());
end

function MessageFrame.OnMessageAnimationFinished (animation)
  animation.parent:RemoveMessage(animation.message);
end

--******************************************************************************
-- message attribute setters
--******************************************************************************

function MessageFrame:SetMessageFont (message)
  self:SetFontStringFont(message.fontString);
end

function MessageFrame:SetMessageTextAlign (message, alignment)
  self:SetFontStringTextAlign(message.fontString, alignment);
end

function MessageFrame:SetMessageShadowColor (message)
  self:SetFontStringShadowColor(message.fontString);
end

function MessageFrame:SetMessageShadowOffset (message)
  self:SetFontStringShadowOffset(message.fontString);
end

--******************************************************************************
-- fontString attribute setters
--******************************************************************************

function MessageFrame:SetFontStringFont (fontString)
  fontString:SetFont(self.font, self.fontSize, self.fontFlags);
end

function MessageFrame:SetFontStringTextAlign (fontString, alignment)
  fontString:SetJustifyH(alignment);
end

function MessageFrame:SetFontStringShadowColor (fontString)
  local colors = self.shadowColors;
  fontString:SetShadowColor(colors.r, colors.g, colors.b, colors.a);
end

function MessageFrame:SetFontStringShadowOffset (fontString)
  fontString:SetShadowOffset(self.shadowOffset.x, self.shadowOffset.y);
end

--******************************************************************************
-- helper methods
--******************************************************************************

function MessageFrame:ForEachMessage (callback, ...)
  self:ForEachActiveMessage(callback, ...);
  self:ForEachInactiveMessage(callback, ...);
end

function MessageFrame:ForEachActiveMessage (callback, ...)
  -- EnumerateActive returns pairs() and uses elements as keys
  for message in self.framePool:EnumerateActive() do
    callback(self, message, ...);
  end
end

function MessageFrame:ForEachInactiveMessage (callback, ...)
  -- EnumerateActive returns ipairs() and uses elements as values
  for _, message in self.framePool:EnumerateInactive() do
    callback(self, message, ...);
  end
end
