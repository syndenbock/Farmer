local _, addon = ...;

local Mixin = _G.Mixin;

local MessageFrame = addon.import('Widget/MessageFrame');

local DataMessageFrame = addon.export('Widget/DataMessageFrame', {});

--##############################################################################
-- private methods
--##############################################################################

local function generateSubspaceIdentifier (self)
  self.subspaceCount = self.subspaceCount + 1;
  return self.subspaceCount;
end

local function getDataByMessage (self, message)
  return self.messageInfo[message];
end

local function getDataBySubspaceAndIdentifier (self, subspace, identifier)
  return self.subspaces[subspace][identifier];
end

local function storeMessageData (self, subspace, identifier, message, data)
  local info = getDataBySubspaceAndIdentifier(self, subspace, identifier);

  if (not info) then
    info = {
      subspace = subspace,
      identifier = identifier,
    };
    self.subspaces[subspace][identifier] = info;
  end

  info.message = message;
  info.data = data;
  self.messageInfo[message] = info;
end

local function deleteMessageData (self, message)
  local info = getDataByMessage(self, message);

  if (info) then
    self.subspaces[info.subspace][info.identifier] = nil;
    self.messageInfo[message] = nil;
  end
end

--##############################################################################
-- public methods
--##############################################################################

function DataMessageFrame:New (options)
  local this = MessageFrame:New (options);

  Mixin(this, DataMessageFrame);

  this.subspaceCount = 0;
  this.subspaces = {};
  this.messageInfo = {};

  this:AddResetCallback(deleteMessageData);

  return this;
end

function DataMessageFrame:CreateSubspace ()
  local identifier = generateSubspaceIdentifier(self);

  self.subspaces[identifier] = {};

  return identifier;
end

function DataMessageFrame:AddMessageWithData (subspace, identifier, data, text, colors)
  return self:AddIconOrAtlasMessageWithdata(subspace, identifier, data, nil, nil, text, colors);
end

function DataMessageFrame:AddIconMessageWithData (subspace, identifier, data, icon, text, colors)
  return self:AddIconOrAtlasMessageWithdata(subspace, identifier, data, icon, nil, text, colors);
end

function DataMessageFrame:AddAtlasMessageWithData (subspace, identifier, data, atlas, text, colors)
  return self:AddIconOrAtlasMessageWithdata(subspace, identifier, data, nil, atlas, text, colors);
end

function DataMessageFrame:AddIconOrAtlasMessageWithdata (subspace, identifier, data, icon, atlas, text, colors)
  local info = getDataBySubspaceAndIdentifier(self, subspace, identifier);
  local message;

  if (info) then
    message = info.message;
    self:UpdateIconMessage(message, icon, text, colors);
  else
    message = self:AddIconMessage(icon, text, colors);
  end

  storeMessageData(self, subspace, identifier, message, data);

  return message;
end

function DataMessageFrame:GetMessageData (subspace, identifier)
  local data = getDataBySubspaceAndIdentifier(self, subspace, identifier);

  return data and data.data;
end

function DataMessageFrame:RemoveMessageByIdentifier (subspace, identifier)
  local data = self.subspaces[subspace][identifier];

  if (data == nil) then
    return;
  end

  self:RemoveMessage(data.message);
end
