local addonName, addon = ...;

local tinsert = _G.tinsert;
local tsort = table.sort;

local CallbackHandler = {};

addon.share('Class').CallbackHandler = CallbackHandler;

CallbackHandler.__index = CallbackHandler;

function CallbackHandler:new ()
  local this = {};

  setmetatable(this, CallbackHandler);
  this.callMap = {};

  return this;
end

function CallbackHandler:addCallback (identifier, callback)
  assert(type(callback) == 'function', 'callback is not a function');

  local callMap = self.callMap;
  local callbacks = callMap[identifier];

  if (callbacks) then
    tinsert(callbacks, callback);
    return false;
  else
    callMap[identifier] = {callback};
    return true;
  end
end

function CallbackHandler:removeCallback (identifier, callback)
  local callbacks = self.callMap[identifier];

  assert(callbacks,
      addonName .. ': no callbacks were registered for ' .. identifier);

  local found = false;

  for x, storedCallback in ipairs(callbacks) do
    if (storedCallback == callback) then
      callbacks[x] = false;
      found = true;
    end
  end

  assert(found,
      addonName .. ': callback was not registered for ' .. identifier);
end

function CallbackHandler:clearCallbacks (identifier)
  self.callMap[identifier] = nil;
end

function CallbackHandler:getIdentifiers ()
  local list = {};

  for identifier in pairs(self.callMap) do
    tinsert(list, identifier);
  end

  return list;
end

function CallbackHandler:getSortedIdentifiers ()
  local identifiers = self:getIdentifiers();

  tsort(identifiers);

  return identifiers;
end

function CallbackHandler:call (identifier, ...)
  local callbacks = self.callMap[identifier];

  if (not callbacks) then
    return false;
  end

  for _, callback in ipairs(callbacks) do
    if (callback) then
      callback(...);
    end
  end

  return true;
end

function CallbackHandler:callAll (...)
  for identifier in pairs(self.callMap) do
    self:call(identifier, ...);
  end
end

function CallbackHandler:clear ()
  self.callMap = {};
end
