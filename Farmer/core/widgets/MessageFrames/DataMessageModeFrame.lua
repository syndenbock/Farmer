local _, ADDON = ...;

local Mixin = _G.Mixin;

local DataMessageFrame = ADDON.import('Widget/DataMessageFrame');

local MESSAGE_MODES = {
  shift = 0,
  replace = 1,
  combine = 2,
  replaceAndMove = 3,
  combineAndMove = 4,
};

local DEFAULT_OPTIONS = {
  mode = MESSAGE_MODES.combineAndMove,
};

local DataMessageModeFrame = ADDON.export('Widget/DataMessageModeFrame', {});

local function doNothing () end

--##############################################################################
-- Shifting mode handlers
--##############################################################################

local ShiftMode = {};

function ShiftMode:AddMessageWithData (subspace, identifier, data, text, colors)
  self:AddIconMessage(nil, text, colors);
end

function ShiftMode:AddIconMessageWithData (subspace, identifier, data, icon, text, colors)
  self:AddIconMessage(icon, text, colors);
end

ShiftMode.GetMessageData = doNothing;

--##############################################################################
-- Replace mode handlers
--##############################################################################

local ReplaceMode = {};

function ReplaceMode:AddMessageWithData (subspace, identifier, data, text, colors)
  return DataMessageFrame.AddMessageWithData(self, subspace, identifier, nil, text, colors);
end

function ReplaceMode:AddIconMessageWithData (subspace, identifier, data, icon, text, colors)
  return DataMessageFrame.AddIconMessageWithData(self, subspace, identifier, nil, icon, text, colors);
end

ReplaceMode.GetMessageData = doNothing;

--##############################################################################
-- Combine mode handlers
--##############################################################################

local CombineMode = {};

CombineMode.AddMessageWithData = DataMessageFrame.AddMessageWithData;
CombineMode.AddIconMessageWithData = DataMessageFrame.AddIconMessageWithData;
CombineMode.GetMessageData = DataMessageFrame.GetMessageData;

--##############################################################################
-- Replace and move mode handlers
--##############################################################################

local ReplaceAndMoveMode = {};

function ReplaceAndMoveMode:AddMessageWithData (...)
  self:MoveMessageToFront(ReplaceMode.AddMessageWithData(self, ...));
end

function ReplaceAndMoveMode:AddIconMessageWithData (...)
  self:MoveMessageToFront(ReplaceMode.AddIconMessageWithData(self, ...));
end

ReplaceAndMoveMode.GetMessageData = doNothing;

--##############################################################################
-- Combine and move mode handlers
--##############################################################################

local CombineAndMoveMode = {};

function CombineAndMoveMode:AddMessageWithData (...)
  self:MoveMessageToFront(DataMessageFrame.AddMessageWithData(self, ...));
end

function CombineAndMoveMode:AddIconMessageWithData (...)
  self:MoveMessageToFront(DataMessageFrame.AddIconMessageWithData(self, ...));
end

CombineAndMoveMode.GetMessageData = DataMessageFrame.GetMessageData;

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
  local modeMap = {
    [MESSAGE_MODES.shift] = ShiftMode,
    [MESSAGE_MODES.replace] = ReplaceMode,
    [MESSAGE_MODES.combine] = CombineMode,
    [MESSAGE_MODES.replaceAndMove] = ReplaceAndMoveMode,
    [MESSAGE_MODES.combineAndMove] = CombineAndMoveMode,
  };

  assert(modeMap[self.mode] ~= nil, 'Unknown message mode: ' .. self.mode);
  self.mode = modeMap[self.mode];
end

function DataMessageModeFrame:AddMessageWithData (...)
  self.mode.AddMessageWithData(self, ...);
end

function DataMessageModeFrame:AddIconMessageWithData (...)
  self.mode.AddIconMessageWithData(self, ...);
end
