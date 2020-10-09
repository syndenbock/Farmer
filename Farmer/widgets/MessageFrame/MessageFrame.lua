local _, addon = ...;

local CreateFontStringPool = _G.CreateFontStringPool;
local CreateFrame = _G.CreateFrame;
local C_Timer = _G.C_Timer;
local UIPARENT = _G.UIParent;
local STANDARD_TEXT_FONT = _G.STANDARD_TEXT_FONT;

local transformFrameAnchorsToCenter = addon.transformFrameAnchorsToCenter;
local Set = addon.Class.Set;

local MessageFrame = {};

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
  anchor:SetPoint('CENTER', UIPARENT, 'CENTER', 0, 0);
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
  this.updateInterval = 0.01;
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
  this.updates = Set:new();
  this.pool = CreateFontStringPool(anchor, this.frameStrata,
      this.frameLevel);

  return this;
end

function MessageFrame:Move (message, callback)
  local anchor = self.anchor;

  self:Clear();
  message = self:AddMessage(message);
  self.lockMessages = true;

  anchor:SetSize(100, 100);
  anchor:RegisterForDrag('LeftButton');
  anchor:EnableMouse(true);
  anchor:SetMovable(true);
  anchor:SetScript('OnDragStart', function (self)
    if (self:IsMovable() == true) then
      self:StartMoving();
    end
  end);
  anchor:SetScript('OnReceiveDrag', function ()
    self.lockMessages = nil;
    self:StartDisplayTimeout(message);
    self:StopMoving();
    if (callback) then
      callback();
    end
  end);
end

function MessageFrame:AddMessage (text, r, g, b, a)
  if (self.lockMessages) then return end

  local fontString = self.pool:Acquire();

  fontString:SetParent(self.anchor);
  self:SetFontStringFont(fontString);
  self:SetFontStringShadowColor(fontString);
  self:SetFontStringShadowOffset(fontString);
  fontString:SetTextColor(r or 1, g or 1, b or 1, a or 1);
  fontString:SetText(text);
  self:InsertMessage(fontString);

  if (self.fading) then
    self:StartDisplayTimeout(fontString);
  end

  fontString:Show();

  return fontString;
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

  self:SetMessagePointsIfExists(tail);

  if (fontString.isFading) then
    self:RemoveAlphaHandler(fontString);
  end

  self.pool:Release(fontString);
  self:ResetFontString(fontString);
end

function MessageFrame:Clear ()
  self:ForEachMessage(self.RemoveMessage);
end

function MessageFrame:SetFading (fading)
  --[[ when toggling from not fading to fading, current permanent messages
  will fade ]]
  if (not self.fading and fading) then
    self:ForEachMessage(self.StartDisplayTimeout);
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
  self:ForEachMessage(self.SetMessagePoints);
end

function MessageFrame:SetFrameStrata (frameStrata)
  self.frameStrata = frameStrata;
  self.anchor:SetFrameStrata(frameStrata);
  self.pool.layer = frameStrata;

  self:ForEachMessage(self.SetFontStringFrameStrata);
end

function MessageFrame:GetFrameStrata ()
  return self.frameStrata;
end

function MessageFrame:SetFrameLevel (frameLevel)
  self.frameLevel = frameLevel;
  self.anchor:SetFrameLevel(frameLevel);
  self.pool.subLayer = frameLevel;

  self:ForEachMessage(self.SetFontStringFrameLevel)
end

function MessageFrame:GetFrameLevel ()
  return self.frameLevel;
end

function MessageFrame:SetFont (font, fontSize, fontFlags)
  self.font = font;
  self.fontSize = fontSize;
  self.fontFlags = fontFlags;

  self:ForEachMessage(self.SetFontStringFont);
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
  self:ForEachMessage(self.SetMessagePoints);
end

function MessageFrame:GetTextAlign ()
  return self.alignment;
end

function MessageFrame:SetGrowDirection (direction)
  self.direction = direction;
  self:ForEachMessage(self.SetMessagePoints);
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

  self:ForEachMessage(self.SetFontStringShadowColor);
end

function MessageFrame:GetShadowColor ()
  local colors = self.shadowColors;

  return colors.r, colors.g, colors.b, colors.a;
end

function MessageFrame:SetShadowOffset (x, y)
  local offset = self.shadowOffset;

  offset.x = x or offset.x;
  offset.y = y or offset.y;

  self:ForEachMessage(self.SetFontStringShadowOffset);
end

function MessageFrame:GetShadowOffset ()
  return self.shadowOffset.x, self.shadowOffset.y;
end

function MessageFrame:SetUpdateInterval (interval)
  self.updateInterval = interval;
end

function MessageFrame:GetUpdateInterval ()
  return self.updateInterval;
end

--[[ aliases for default frame methods ]]
MessageFrame.SetJustifyH = MessageFrame.SetTextAlign;
MessageFrame.GetJustifyH = MessageFrame.GetTextAlign;
MessageFrame.SetInsertMode = MessageFrame.SetGrowDirection;
MessageFrame.GetInsertMode = MessageFrame.GetGrowDirection;
MessageFrame.SetTimeVisible = MessageFrame.SetVisibleTime;
MessageFrame.GetTimeVisible = MessageFrame.GetVisibleTime;

--##############################################################################
-- private methods
--##############################################################################

function MessageFrame:StopMoving ()
  local anchor = self.anchor;

  anchor:EnableMouse(false);
  anchor:SetMovable(false);
  anchor:StopMovingOrSizing();
  anchor:SetScript('OnDragStart', nil);
  anchor:SetScript('OnReceiveDrag', nil);
  transformFrameAnchorsToCenter(anchor);
  anchor:SetSize(2, 2);
end

function MessageFrame:ResetFontString (fontString)
  --[[ no need to reset default attributes, as the pool resetter automatically
    does this ]]
  fontString.head = nil;
  fontString.tail = nil;
  fontString.isFading = nil;
  fontString.fadeSpeed = nil;
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
  self:SetMessagePointsIfExists(head);
end

--******************************************************************************
-- message positioning methods
--******************************************************************************

function MessageFrame:SetMessagePoints (fontString)
  local head = fontString.head;
  local alignmentAnchor;
  local anchorPoint;

  if (self.alignment == 'LEFT') then
    alignmentAnchor = 'LEFT';
  elseif (self.alignment == 'RIGHT') then
    alignmentAnchor = 'RIGHT';
  else
    alignmentAnchor = '';
  end

  if (self.direction == 'UP') then
    anchorPoint = 'BOTTOM' .. alignmentAnchor;
  else
    anchorPoint = 'TOP' .. alignmentAnchor;
  end

  fontString:ClearAllPoints();

  if (head) then
    local headAnchorPoint;
    local yOffset;

    if (self.direction == 'UP') then
      yOffset = self.spacing;
      headAnchorPoint = 'TOP' .. alignmentAnchor;
    else
      yOffset = -self.spacing;
      headAnchorPoint = 'BOTTOM' .. alignmentAnchor;
    end

    fontString:SetPoint(anchorPoint, head, headAnchorPoint, 0, yOffset);
  else
    fontString:SetPoint(anchorPoint, self.anchor, 'CENTER', 0, 0);
  end
end

function MessageFrame:SetMessagePointsIfExists (fontString)
  if (not fontString) then return end

  self:SetMessagePoints(fontString);
end

function MessageFrame:AttachFontString (head, tail)
  if (head) then
    head.tail = tail;
  end

  if (tail) then
    tail.head = head;
  end
end

--******************************************************************************
-- fontString visibility methods
--******************************************************************************

function MessageFrame:StartDisplayTimeout (fontString)
  if (self.lockMessages) then return end

  local visibleTime = self.visibleTime or 0;

  if (visibleTime > 0) then
    C_Timer.After(visibleTime, function ()
      self:FadeMessage(fontString);
    end);
  else
    self:FadeMessage(fontString);
  end
end

function MessageFrame:FadeMessage (fontString)
  if (self.lockMessages) then return end

  assert(fontString.isFading ~= true, 'message is already fading');

  --[[ fontString was removed by something like Clear ]]
  if (not self.pool:IsActive(fontString)) then
    return;
  end

  local fadeDuration = self.fadeDuration;

  if (not fadeDuration or fadeDuration <= 0) then
    self:RemoveMessage(fontString);
    return;
  end

  fontString.isFading = true;
  fontString.fadeSpeed = fontString:GetAlpha() / fadeDuration;

  self:AddAlphaHandler(fontString);
end

function MessageFrame:AddAlphaHandler (fontString)
  if (self.updates:getItemCount() == 0) then
    self:InitUpdateHandler();
  end

  self.updates:addItem(fontString);
end

function MessageFrame:InitUpdateHandler ()
  local this = self;

  self.elapsed = 0;

  self.anchor:SetScript('OnUpdate', function (_, elapsed)
    elapsed = this.elapsed + elapsed;

    if (elapsed >= this.updateInterval) then
      this:HandleUpdate(elapsed);
      self.elapsed = 0;
    else
      self.elapsed = elapsed;
    end
  end);
end

function MessageFrame:HandleUpdate (elapsed)
  self.updates:forEach(function (fontString)
    self:HandleMessageFade(fontString, elapsed);
  end);
end

function MessageFrame:HandleMessageFade (fontString, elapsed)
  assert(fontString.isFading == true, 'message is not fading!');

  local alpha = fontString:GetAlpha() - fontString.fadeSpeed * elapsed, 0;

  if (alpha > 0) then
    fontString:SetAlpha(alpha);
  else
    self:RemoveMessage(fontString);
    self:RemoveAlphaHandler(fontString);
  end
end

function MessageFrame:RemoveAlphaHandler (fontString)
  self.updates:removeItem(fontString);

  if (self.updates:getItemCount() == 0) then
    self.anchor:SetScript('OnUpdate', nil);
  end
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
