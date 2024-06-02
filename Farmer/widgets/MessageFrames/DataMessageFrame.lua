local _, addon = ...;

local CreateFromMixins = _G.CreateFromMixins;

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
  local this = CreateFromMixins(DataMessageFrame);

  this.subspaceCount = 0;
  this.subspaces = {};
  this.messageInfo = {};

  this.messageFrame = MessageFrame:New(options);
  this.messageFrame:AddResetCallback(function (message)
    deleteMessageData(this, message);
  end);

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
    self.messageFrame:UpdateIconMessage(message, icon, text, colors);
  else
    message = self.messageFrame:AddIconMessage(icon, text, colors);
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

  self.messageFrame:RemoveMessage(data.message);
end

--##############################################################################
-- method proxies
--##############################################################################

local function proxyMethod (methodName)
  DataMessageFrame[methodName] = function (self, ...)
    return self.messageFrame[methodName](self.messageFrame, ...);
  end
end

proxyMethod('SetFont');
proxyMethod('Move');
proxyMethod('SetSpacing');
proxyMethod('AddMessage');
proxyMethod('AddAnchorMessage');
proxyMethod('SetIconScale');
proxyMethod('SetVisibleTime');
proxyMethod('SetGrowDirection');
proxyMethod('SetTextAlign');
proxyMethod('AddIconMessage');
proxyMethod('AddAtlasMessage');
proxyMethod('GetFadeDuration');
proxyMethod('SetFadeDuration');
proxyMethod('MoveMessageToFront');

proxyMethod('ClearAllPoints');
proxyMethod('SetPoint');
proxyMethod('GetCenter');
proxyMethod('SetFrameStrata');
proxyMethod('GetFrameStrata');
proxyMethod('SetFrameLevel');
proxyMethod('GetFrameLevel');
proxyMethod('GetScale');
proxyMethod('GetEffectiveScale');
proxyMethod('SetJustifyH');
proxyMethod('GetJustifyH');
proxyMethod('SetTextAlign');
proxyMethod('GetTextAlign');
proxyMethod('SetTimeVisible');
proxyMethod('GetTimeVisible');
proxyMethod('SetVisibleTime');
proxyMethod('GetVisibleTime');
