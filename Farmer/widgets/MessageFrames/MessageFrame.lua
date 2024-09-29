local _, addon = ...;

local max = _G.max;
local tinsert = _G.tinsert;

local CreateUnsecuredFramePool = _G.CreateUnsecuredFramePool or _G.CreateFramePool;
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

local DEFAULT_COLOR = {r = 1, g = 1, b = 1, a = 1};
local ICON_OFFSET = 3;

local DEFAULT_OPTIONS = {
  alignment = ALIGNMENT_CENTER,
  frameStrata = 'DIALOG',
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

local MessageFrame = addon.export('Widget/MessageFrame', {
  GROW_DIRECTION_UP = GROW_DIRECTION_UP,
  GROW_DIRECTION_DOWN = GROW_DIRECTION_DOWN,
  ALIGNMENT_LEFT = ALIGNMENT_LEFT,
  ALIGNMENT_CENTER = ALIGNMENT_CENTER,
  ALIGNMENT_RIGHT = ALIGNMENT_RIGHT,
  INSERTMODE_PREPEND = INSERTMODE_PREPEND,
  INSERTMODE_APPEND = INSERTMODE_APPEND,
});

--##############################################################################
-- private methods
--##############################################################################

--******************************************************************************
-- helper methods
--******************************************************************************

local function forEachActiveMessage (self, callback, ...)
  -- EnumerateActive returns pairs() and uses elements as keys
  for message in self.framePool:EnumerateActive() do
    callback(self, message, ...);
  end
end

local function enumerateInactiveFrames (self)
  -- F****** HELL BLIZZARD WHY DO YOU DELETE STUFF THAT WE USE?!
  if (self.framePool.EnumerateInactive ~= nil) then
    return self.framePool:EnumerateInactive();
  else
    return ipairs(self.framePool.inactiveObjects);
  end
end

local function forEachInactiveMessage (self, callback, ...)
  for _, message in enumerateInactiveFrames(self) do
    callback(self, message, ...);
  end
end

local function forEachMessage (self, callback, ...)
  forEachActiveMessage(self, callback, ...);
  forEachInactiveMessage(self, callback, ...);
end

local function assertMessageIsActive (self, message)
  assert(self.framePool:IsActive(message), 'message is not currently displayed!');
end

--******************************************************************************
-- initialization methods
--******************************************************************************

local function createAnchor (name, frameStrata, frameLevel)
  local anchor = CreateFrame('Frame', name, UIPARENT);

  anchor:SetSize(2, 2);
  anchor:SetPoint(ANCHOR_CENTER, UIPARENT, ANCHOR_CENTER, 0, 0);
  anchor:SetFrameStrata(frameStrata);
  anchor:SetFrameLevel(frameLevel);
  anchor:Show();

  return anchor;
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

local function readOptions (self, options)
  options = transformOptions(options);
  addon.readOptions(DEFAULT_OPTIONS, options, self);
end

--******************************************************************************
-- message positioning methods
--******************************************************************************

local function attachMessage (head, tail)
  if (head) then
    head.tail = tail;
  end

  if (tail) then
    tail.head = head;
  end
end

local function setMessagePoints (self, message)
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

local function setMessagePointsIfExists (self, message)
  if (not message) then return end

  setMessagePoints(self, message);
end

local function invertMessageDirection (self, message)
  --[[ Only use this function when applying it to all messages in the chain.
    Otherwise, this will cause a loop in the chain. ]]
  local head = message.head;

  message.head = message.tail;
  message.tail = head;

  setMessagePoints(self, message);
end

local function removeMessageAnchors (self, message)
  local head = message.head;
  local tail = message.tail;

  attachMessage(head, tail);

  if (self.head == message) then
    self.head = tail;
  end

  if (self.tail == message) then
    self.tail = head;
  end

  message.tail = nil;
  message.head = nil;

  setMessagePointsIfExists(self, tail);
end

--******************************************************************************
-- message insertion methods
--******************************************************************************

local function appendMessage (self, message)
  attachMessage(self.tail, message);

  self.head = self.head or message;
  self.tail = message;

  setMessagePoints(self, message);
end

local function prependMessage (self, message)
  local head = self.head;

  attachMessage(message, head);

  self.head = message;
  self.tail = self.tail or message;

  setMessagePoints(self, message);
  setMessagePointsIfExists(self, head);
end

local function insertMessage (self, message)
  if (self.insertMode == INSERTMODE_PREPEND) then
    prependMessage(self, message);
  else
    appendMessage(self, message);
  end
end

local function removeMessage (self, message)
  removeMessageAnchors(self, message);
  self.framePool:Release(message);
end

--******************************************************************************
-- message animation methods
--******************************************************************************

local function OnMessageAnimationFinished (animation)
  removeMessage(animation.parent, animation.message);
end

local function CreateMessageAnimation (self, message)
  local animationGroup = message.animationGroup;
  local animation = message.animation;

  if (not animationGroup) then
    animationGroup = message:CreateAnimationGroup();
    message.animationGroup = animationGroup;
  else
    animationGroup:Stop();
  end

  if (not animation) then
    animation = animationGroup:CreateAnimation('Alpha');

    animation:SetToAlpha(0);
    animation:SetOrder(1);
    animation.parent = self;
    animation.message = message;

    animation:SetScript('OnFinished', OnMessageAnimationFinished);
    message.animation = animation;
  end

  animation:SetStartDelay(self.visibleTime);
  animation:SetDuration(self.fadeDuration);
  animation:SetFromAlpha(message:GetAlpha());

  animationGroup:Play();
end

local function startMessageAnimation (self, message)
  if (self.visibleTime <= 0 and self.fadeDuration <= 0) then
    removeMessage(message);
    return;
  end

  CreateMessageAnimation(self, message);
end

--******************************************************************************
-- frame moving methods
--******************************************************************************

local function startMovingAnchor (anchor)
  if (anchor:IsMovable() == true) then
    anchor:StartMoving();
  end
end

local function stopMovingAnchor (anchor)
  anchor:RegisterForDrag();
  anchor:EnableMouse(false);
  anchor:SetMovable(false);
  anchor:StopMovingOrSizing();
  anchor:SetScript(ON_MOUSE_DOWN, nil);
  anchor:SetScript(ON_MOUSE_UP, nil);
end

local function startMoving (self, message, callback)
  if (self.isMoving) then return end

  local anchor = self.anchor;

  self.isMoving = true;

  anchor:EnableMouse(true);
  anchor:SetMovable(true);

  anchor:SetScript(ON_MOUSE_DOWN, startMovingAnchor);
  anchor:SetScript(ON_MOUSE_UP, function ()
    self.isMoving = false;
    stopMovingAnchor(anchor);
    transformFrameAnchorsToCenter(anchor);
    anchor:SetSize(20, 20);
    startMessageAnimation(self, message);

    if (callback) then
      callback();
    end
  end);
end

local function resizeMessage (self, message)
  local textWidth, textHeight = message.fontString:GetSize();
  local iconSize = self.iconSize;

  message.iconFrame:SetSize(iconSize, iconSize);
  message:SetSize(iconSize + ICON_OFFSET + textWidth, max(iconSize, textHeight));
end

local function updateSizes (self)
  self.iconSize = self.fontSize * self.iconScale;
  forEachActiveMessage(self, resizeMessage);
end

--******************************************************************************
-- fontString attribute setters
--******************************************************************************

local function setFontStringFont (self, fontString)
  fontString:SetFont(self.font, self.fontSize, self.fontFlags);
end

local function setFontStringTextAlign (self, fontString, alignment)
  fontString:SetJustifyH(alignment);
end

local function setFontStringShadowColor (self, fontString)
  local colors = self.shadowColors;
  fontString:SetShadowColor(colors.r, colors.g, colors.b, colors.a);
end

local function setFontStringShadowOffset (self, fontString)
  fontString:SetShadowOffset(self.shadowOffset.x, self.shadowOffset.y);
end

--******************************************************************************
-- message attribute setters
--******************************************************************************

local function setMessageFont (self, message)
  setFontStringFont(self, message.fontString);
end

local function setMessageTextAlign (self, message, alignment)
  setFontStringTextAlign(self, message.fontString, alignment);
end

local function setMessageShadowColor (self, message)
  setFontStringShadowColor(self, message.fontString);
end

local function setMessageShadowOffset (self, message)
  setFontStringShadowOffset(self, message.fontString);
end

--******************************************************************************
-- message creation methods
--******************************************************************************

local function createFontString (self, parent)
  local fontString = parent:CreateFontString();

  fontString:SetParent(parent);
  fontString:SetPoint(ANCHOR_RIGHT, parent, ANCHOR_RIGHT, 0, 0);
  fontString:Show();

  setFontStringFont(self, fontString);
  setFontStringTextAlign(self, fontString, self.alignment);
  setFontStringShadowColor(self, fontString);
  setFontStringShadowOffset(self, fontString);

  return fontString;
end

local function createIconFrame (parent)
  local iconFrame = parent:CreateTexture(LAYER_ARTWORK);

  iconFrame:SetParent(parent);
  iconFrame:SetPoint(ANCHOR_LEFT, parent, ANCHOR_LEFT, 0, 0);

  return iconFrame;
end

local function applyMessageColor (message, colors)
  if (colors) then
    message.fontString:SetTextColor(
      colors.r or DEFAULT_COLOR.r,
      colors.g or DEFAULT_COLOR.g,
      colors.b or DEFAULT_COLOR.b,
      colors.a or DEFAULT_COLOR.a
    );
  else
    message.fontString:SetTextColor(
      DEFAULT_COLOR.r,
      DEFAULT_COLOR.g,
      DEFAULT_COLOR.b,
      DEFAULT_COLOR.a
    );
  end
end

local function applyMessageAttributes (self, message, icon, atlas, text, colors)
  if (message.fontString == nil) then
    message.fontString = createFontString(self, message);
  end

  if (message.iconFrame == nil) then
    message.iconFrame = createIconFrame(message);
  end

  applyMessageColor(message, colors);
  message.fontString:SetText(text);
  resizeMessage(self, message);
  message:Show();

  if (icon) then
    message.iconFrame:SetTexture(icon);
    message.iconFrame:Show();
  elseif (atlas) then
    message.iconFrame:SetAtlas(atlas);
    message.iconFrame:Show();
  else
    message.iconFrame:Hide();
  end

  if (self.fading) then
    startMessageAnimation(self, message);
  end

  return message;
end

local function createMessage (self, icon, atlas, text, colors)
  return applyMessageAttributes(self, self.framePool:Acquire(), icon, atlas,
      text, colors);
end

local function createAnchorMessage (self, icon, text, colors)
  -- Setting an anchor text doesn't properly work yet as the message itself
  -- cannot be dragged which causes parts of the message not being able to
  -- clicked if they don't overlap the moving anchor.
  local message = createMessage(self, icon, nil, nil, colors);

  setMessagePoints(self, message);

  return message;
end

local function resetMessage (message)
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

local function addResetCallback (self, callback)
  tinsert(self.resetCallbacks, 1, callback);
end

local function executeResetCallbacks (self, message)
  for _, callback in ipairs(self.resetCallbacks) do
    callback(self, message);
  end
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
  this.resetCallbacks = {};

  this.framePool = CreateUnsecuredFramePool(FRAME, this.anchor, nil, function (pool, message)
    executeResetCallbacks(this, message);
    resetMessage(message);
  end, false);

  updateSizes(this);

  return this;
end

MessageFrame.AddResetCallback = addResetCallback;

function MessageFrame:Move (icon, text, callback)
  local message = createAnchorMessage(self, icon, text);

  transformFrameAnchorsToCenter(self.anchor);
  self.anchor:SetSize(200, 200);
  startMoving(self, message, callback);
end

function MessageFrame:AddMessage (text, colors)
  return MessageFrame.AddAtlasOrIconMessage(self, nil, nil, text, colors);
end

function MessageFrame:AddIconMessage (icon, text, colors)
  return MessageFrame.AddAtlasOrIconMessage(self, icon, nil, text, colors);
end

function MessageFrame:AddAtlasMessage (atlas, text, colors)
  return MessageFrame.AddAtlasOrIconMessage(self, nil, atlas, text, colors);
end

function MessageFrame:AddAtlasOrIconMessage (icon, atlas, text, colors)
  local message = createMessage(self, icon, atlas, text, colors);

  insertMessage(self, message);

  return message;
end

function MessageFrame:AddAnchorMessage (icon, text, colors)
  createAnchorMessage(self, icon, text, colors);
end

function MessageFrame:RemoveMessage (message)
  assertMessageIsActive(self, message);
  removeMessage(self, message);
end

function MessageFrame:UpdateMessage (message, text, colors)
  MessageFrame.UpdateIconOrAtlasMessage(self, message, nil, nil, text, colors);
end

function MessageFrame:UpdateIconMessage (message, icon, text, colors)
  MessageFrame.UpdateIconOrAtlasMessage(self, message, icon, nil, text, colors);
end

function MessageFrame:UpdateAtlasMessage (message, atlas, text, colors)
  MessageFrame.UpdateIconOrAtlasMessage(self, message, nil, atlas, text, colors);
end

function MessageFrame:UpdateIconOrAtlasMessage (message, icon, atlas, text, colors)
  assertMessageIsActive(self, message);
  applyMessageAttributes(self, message, icon, atlas, text, colors);
end

function MessageFrame:MoveMessageToFront (message)
  assertMessageIsActive(self, message);

  if (self.head == message) then
    return;
  end

  removeMessageAnchors(self, message);
  insertMessage(self, message);
end

function MessageFrame:Clear ()
  forEachActiveMessage(self, removeMessage);
end

function MessageFrame:SetFading (fading)
  --[[ when toggling from not fading to fading, current permanent messages
  will fade ]]
  if (not self.fading and fading) then
    forEachActiveMessage(self, startMessageAnimation);
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
  forEachActiveMessage(self, setMessagePoints);
end

function MessageFrame:SetFont (font, fontSize, fontFlags)
  self.font = font;
  self.fontSize = fontSize;
  self.fontFlags = fontFlags;

  forEachMessage(self, setMessageFont);
  updateSizes(self);
end

function MessageFrame:SetIconScale (scale)
  self.iconScale = scale;
  updateSizes(self);
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
  forEachMessage(self, setMessageTextAlign, alignment);
  forEachActiveMessage(self, setMessagePoints);
end

function MessageFrame:GetTextAlign ()
  return self.alignment;
end

function MessageFrame:SetGrowDirection (direction)
  self.direction = direction;
  forEachActiveMessage(self, setMessagePoints);
end

function MessageFrame:GetGrowDirection ()
  return self.direction;
end

function MessageFrame:SetShadowColor (colors)
  local currentColors = self.shadowColors;

  currentColors.r = colors.r or currentColors.r;
  currentColors.g = colors.g or currentColors.g;
  currentColors.b = colors.b or currentColors.b;
  currentColors.a = colors.a or currentColors.a;

  forEachActiveMessage(self, setMessageShadowColor);
end

function MessageFrame:SetInsertMode (insertMode)
  if ((self.insertMode == INSERTMODE_PREPEND) ~=
      (insertMode == INSERTMODE_PREPEND)) then
    forEachActiveMessage(self, invertMessageDirection);
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

  forEachActiveMessage(self, setMessageShadowOffset);
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
