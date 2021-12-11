local ADDON_NAME, ADDON = ...;

local geterrorhandler = _G.geterrorhandler;
local Mixin = _G.Mixin;

local DataMessageFrame = ADDON.Widget.DataMessageFrame;

local MESSAGE_MODES = {
  shift = 0,
  replace = 1,
  combine = 2,
};

local DEFAULT_OPTIONS = {
  mode = MESSAGE_MODES.combine,
};

local DataMessageModeFrame = {};

ADDON.share('Widget').DataMessageModeFrame = DataMessageModeFrame;

--##############################################################################
-- Shifting mode handlers
--##############################################################################

local ShiftMode = {};

function ShiftMode:AddMessageWithData (subspace, identifier, data, text, r, g, b, a)
  self:AddIconMessage(nil, text, r, g, b, a);
end

function ShiftMode:AddIconMessageWithData (subspace, identifier, data, icon, text, r, g, b, a)
  self:AddIconMessage(icon, text, r, g, b, a);
end

function ShiftMode:GetMessageData (subspace, identifier)
  return nil;
end

--##############################################################################
-- Replace mode handlers
--##############################################################################

local ReplaceMode = {};

function ReplaceMode:AddMessageWithData (subspace, identifier, data, text, r, g, b, a)
  DataMessageFrame.AddMessageWithData(self, subspace, identifier, nil, nil, text, r, g, b, a);
end

function ReplaceMode:AddIconMessageWithData (subspace, identifier, data, icon, text, r, g, b, a)
  DataMessageFrame.AddIconMessageWithData(self, subspace, identifier, nil, icon, text, r, g, b, a);
end

function ReplaceMode:GetMessageData ()
  return nil;
end

--##############################################################################
-- Combine mode handlers
--##############################################################################

local CombineMode = {};

function CombineMode:AddMessageWithData (subspace, identifier, data, text, r, g, b, a)
  DataMessageFrame.AddMessageWithData(self, subspace, identifier, data, nil, text, r, g, b, a);
end

function CombineMode:AddIconMessageWithData (subspace, identifier, data, icon, text, r, g, b, a)
  DataMessageFrame.AddIconMessageWithData(self, subspace, identifier, data, icon, text, r, g, b, a);
end

CombineMode.GetMessageData = DataMessageFrame.GetMessageData;

--##############################################################################
-- DataMessageModeFrame class
--##############################################################################

function DataMessageModeFrame:New (options)
  local this = DataMessageFrame:New(options);

  Mixin(this, DataMessageModeFrame);
  ADDON.readOptions(DEFAULT_OPTIONS, options, this);
  this:applyMode();

  return this;
end

function DataMessageModeFrame:applyMode ()
  if (self.mode == MESSAGE_MODES.shift) then
    Mixin(self, ShiftMode);
    return;
  end

  if (self.mode == MESSAGE_MODES.replace) then
    Mixin(self, ReplaceMode);
    return;
  end

  if (self.mode == MESSAGE_MODES.combine) then
    Mixin(self, CombineMode);
    return;
  end

  geterrorhandler()('Unknown message mode: ' .. self.mode);
  Mixin(self, ShiftMode);
end
