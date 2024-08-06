local addonName, addon = ...;

local CreateFromMixins = _G.CreateFromMixins;
local tinsert = _G.tinsert;
local tsort = table.sort;
local wipe = _G.wipe;

local secureCall = addon.secureCall;

local CallbackHandler = addon.export('Class/CallbackHandler', {});

function CallbackHandler:new ()
  local this = CreateFromMixins(CallbackHandler);

  this.callbacks = {};

  return this;
end

function CallbackHandler:__callCallbacks (identifier, ...)
  for callback in pairs(self.callbacks[identifier]) do
    secureCall(callback, ...);
  end
end

function CallbackHandler:addCallback (identifier, callback)
  assert(type(callback) == 'function', 'callback is not a function');

  if (self.callbacks[identifier] == nil) then
    self.callbacks[identifier] = {
      [callback] = true,
    };
    return true;
  else
    assert(self.callbacks[identifier][callback] == nil,
        'callback was already registered for ' .. identifier);

    self.callbacks[identifier][callback] = true;
    return false;
  end
end

function CallbackHandler:add (identifier, callback)
  if (type(identifier) == "table") then
    for _, _identifier in ipairs(identifier) do
      self:addCallback(_identifier, callback)
    end
  else
    self:addCallback(identifier, callback)
  end
end

function CallbackHandler:call (identifier, ...)
  if (self.callbacks[identifier] == nil) then
    return false;
  end

  self:__callCallbacks(identifier, ...);

  return true;
end

function CallbackHandler:removeCallback (identifier, callback)
  local callbacks = self.callbacks[identifier];

  assert(callbacks ~= nil,
      addonName .. ': no callbacks were registered for ' .. identifier);

  assert(callbacks[callback] ~= nil,
      addonName .. ': callback was not registered for ' .. identifier);

  callbacks[callback] = nil;

  if (next(callbacks) == nil) then
    self.callbacks[identifier] = nil;
    return true;
  else
    return false;
  end
end

function CallbackHandler:has (identifier, callback)
  return (self.callbacks[identifier] ~= nil and
      self.callbacks[identifier][callback] ~= nil);
end

function CallbackHandler:clear ()
  wipe(self.callbacks);
end

function CallbackHandler:clearCallbacks (identifier)
  self.callbacks[identifier] = nil;
end

function CallbackHandler:callAll (...)
  for identifier in pairs(self.callbacks) do
    self:call(identifier, ...);
  end
end

function CallbackHandler:getIdentifiers ()
  local list = {};

  for identifier in pairs(self.callbacks) do
    tinsert(list, identifier);
  end

  return list;
end

function CallbackHandler:getSortedIdentifiers ()
  local identifiers = self:getIdentifiers();

  tsort(identifiers);

  return identifiers;
end
