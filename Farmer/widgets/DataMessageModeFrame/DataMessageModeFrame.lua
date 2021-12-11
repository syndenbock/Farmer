local ADDON_NAME, ADDON = ...;

local Mixin = _G.Mixin;

local DataMessageFrame = ADDON.Widget.DataMessageFrame;

local MESSAGE_MODES = {
  shift = 0,
};

local DEFAULT_OPTIONS = {
  mode = MESSAGE_MODES.shift,
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
-- DataMessageModeFrame class
--##############################################################################

function DataMessageModeFrame:New (options)
  local this = DataMessageFrame:New(options);

  print(this.CreateSubspace);

  Mixin(this, DataMessageModeFrame);
  ADDON.readOptions(DEFAULT_OPTIONS, options, this);
  this:applyMode();

  return this;
end

function DataMessageModeFrame:applyMode ()
  Mixin(self, ShiftMode);
end
