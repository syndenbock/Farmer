local _, addon = ...;

local Mixin = _G.Mixin;

local MessageFrame = addon.Widget.MessageFrame;

local DataMessageFrame = {};

addon.share('Widget').DataMessageFrame = DataMessageFrame;

function DataMessageFrame:New (options)
  local this = MessageFrame:New(options);

  Mixin(this, DataMessageFrame);
  this.subspaces = {};

  return this;
end

function DataMessageFrame:CreateSubspace ()
  local identifier = self:GenerateSubspaceIdentifier();

  self.subspaces[identifier] = {};

  return identifier;
end

function DataMessageFrame:GenerateSubspaceIdentifier ()
  local identifier = self.subspaceIdentifier or 1;
  self.subspaceIdentifier = identifier + 1;
  return identifier;
end

function DataMessageFrame:AddMessageWithData (subspace, identifier, data, text, r, g, b, a)
  DataMessageFrame.AddIconMessageWithData(self, subspace, identifier, data, nil, text, r, g, b, a);
end

function DataMessageFrame:AddIconMessageWithData (subspace, identifier, data, icon, text, r, g, b, a)
  local info = self:GetMessageInfo(subspace, identifier);
  local message;

  if (info) then
    MessageFrame.RemoveMessage(self, info.message);
  end

  message = self:AddIconMessage(icon, text, r, g, b, a);

  self:SetMessageData(subspace, identifier, message, data);

  return message;
end

function DataMessageFrame:RemoveMessage (message)
  self:RemoveMessageData(message);
  MessageFrame.RemoveMessage(self, message);
end

function DataMessageFrame:SetMessageData (subspace, identifier, message, data)
  local info = self:GetMessageInfo(subspace, identifier);

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

function DataMessageFrame:GetMessageInfo (subspace, identifier)
  return self.subspaces[subspace][identifier];
end

function DataMessageFrame:GetMessageData (subspace, identifier)
  local data = self:GetMessageInfo(subspace, identifier);

  return data and data.data;
end

function DataMessageFrame:RemoveMessageData (message)
  if (message.subspace == nil or message.identifier == nil) then
    return;
  end

  self:RemoveMessageDataByIdentifier(message.subspace, message.identifier);
end

function DataMessageFrame:RemoveMessageDataByIdentifier (subspace, identifier)
  self.subspaces[subspace][identifier] = nil;
end

function DataMessageFrame:RemoveMessageByIdentifier (subspace, identifier)
  local data = self.subspaces[subspace][identifier];

  if (data == nil) then
    return;
  end

  self:RemoveMessage(data.message);
end

function DataMessageFrame:ResetFontString (fontString)
  fontString.subspace = nil;
  fontString.identifier = nil;
  MessageFrame.ResetFontString(self, fontString);
end
