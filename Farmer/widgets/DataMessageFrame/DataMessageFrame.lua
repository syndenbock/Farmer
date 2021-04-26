local _, addon = ...;

local MessageFrame = addon.Widget.MessageFrame;
local DataMessageFrame = {};

addon.share('Widget').DataMessageFrame = DataMessageFrame;

DataMessageFrame.__index = DataMessageFrame;

setmetatable(DataMessageFrame, {
  __index = MessageFrame,
  __call = function (self, ...)
    return self:New(...);
  end
});

function DataMessageFrame:New (options)
  local this = MessageFrame.New(DataMessageFrame, options);

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
  local message = self:AddMessage(text, r, g, b, a);

  self:RemoveMessageByIdentifier(subspace, identifier);
  self:SetMessageData(subspace, identifier, message, data);
  message.subspace = subspace;
  message.identifier = identifier;

  return message;
end

function DataMessageFrame:RemoveMessage (message)
  MessageFrame.RemoveMessage(self, message);
  self:RemoveMessageData(message);
end

function DataMessageFrame:SetMessageData (subspace, identifier, message, data)
  self.subspaces[subspace][identifier] = {
    message = message,
    data = data,
  };
end

function DataMessageFrame:GetMessageData (subspace, identifier)
  local data = self.subspaces[subspace][identifier];

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
