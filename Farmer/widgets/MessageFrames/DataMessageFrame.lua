local _, addon = ...;

local Mixin = _G.Mixin;

local MessageFrame = addon.import('Widget/MessageFrame');

local DataMessageFrame = addon.export('Widget/DataMessageFrame', {});

--##############################################################################
-- private methods
--##############################################################################

local function generateSubspaceIdentifier (self)
  local identifier = self.subspaceIdentifier or 1;
  self.subspaceIdentifier = identifier + 1;
  return identifier;
end

local function getMessageInfo (self, subspace, identifier)
  return self.subspaces[subspace][identifier];
end

local function setMessageData (self, subspace, identifier, message, data)
  local info = getMessageInfo(self, subspace, identifier);

  message.subspace = subspace;
  message.identifier = identifier;

  if (not info) then
    self.subspaces[subspace][identifier] = {
      message = message,
      data = data,
    };
  else
    info.message = message;
    info.data = data;
  end
end

local function removeMessageData (self, message)
  if (message.subspace ~= nil and message.identifier ~= nil) then
    self.subspaces[message.subspace][message.identifier] = nil;
    message.subspace = nil;
    message.identifier = nil;
  end
end

local function resetMessage (self, pool, message)
  removeMessageData(self, message);
end

--##############################################################################
-- public methods
--##############################################################################

function DataMessageFrame:New (options)
  local this = MessageFrame:New(options);

  Mixin(this, DataMessageFrame);
  this.subspaces = {};
  this:AddResetCallback(resetMessage);

  return this;
end

function DataMessageFrame:CreateSubspace ()
  local identifier = generateSubspaceIdentifier(self);

  self.subspaces[identifier] = {};

  return identifier;
end

function DataMessageFrame:AddMessageWithData (subspace, identifier, data, text, colors)
  return DataMessageFrame.AddIconOrAtlasMessageWithdata(self, subspace, identifier, data, nil, nil, text, colors);
end

function DataMessageFrame:AddIconMessageWithData (subspace, identifier, data, icon, text, colors)
  return DataMessageFrame.AddIconOrAtlasMessageWithdata(self, subspace, identifier, data, icon, nil, text, colors);
end

function DataMessageFrame:AddAtlasMessageWithData (subspace, identifier, data, atlas, text, colors)
  return DataMessageFrame.AddIconOrAtlasMessageWithdata(self, subspace, identifier, data, nil, atlas, text, colors);
end

function DataMessageFrame:AddIconOrAtlasMessageWithdata (subspace, identifier, data, icon, atlas, text, colors)
  local info = getMessageInfo(self, subspace, identifier);
  local message;

  if (info) then
    message = info.message;
    MessageFrame.UpdateIconMessage(self, message, icon, text, colors);
  else
    message = MessageFrame.AddIconMessage(self, icon, text, colors);
  end

  setMessageData(self, subspace, identifier, message, data);

  return message;
end

function DataMessageFrame:GetMessageData (subspace, identifier)
  local data = getMessageInfo(self, subspace, identifier);

  return data and data.data;
end

function DataMessageFrame:RemoveMessageByIdentifier (subspace, identifier)
  local data = self.subspaces[subspace][identifier];

  if (data == nil) then
    return;
  end

  MessageFrame.RemoveMessage(self, data.message);
end
