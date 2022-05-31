local _, addon = ...;

local strsplit = _G.strsplit;
local tremove = _G.tremove;

addon.debugging = false;

if (addon.debugging) then
  local proxy = {
    __metatable = false,
  };
  proxy.__index = proxy;
  proxy.__newindex = function (_, key, value)
    assert(proxy[key] == nil, 'Addon key already in use: ' .. key);

    proxy[key] = value;
  end

  setmetatable(addon, proxy);
end

local function splitPathString (pathString)
  return {strsplit('/', pathString)};
end

local function generateNameSpaces (pathList)
  local current = addon;

  for _, name in ipairs(pathList) do
    assert(type(current) == 'table', 'Parent namespace is not a table: ' .. name);

    if (current[name] == nil) then
      current[name] = {};
    end

    current = current[name];
  end

  return current;
end

local function extend (class, key, value)
  assert(class[key] == nil, 'Key already in use: ' .. key);
  class[key] = value;
  return value;
end

addon.extend = extend;

function addon.export (pathString, value)
  assert(value ~= nil, 'Export value is nil');

  local pathList = splitPathString(pathString);
  local name = tremove(pathList);
  local shared = generateNameSpaces(pathList);

  return extend(shared, name, value);
end

function addon.import (pathString)
  local pathList = splitPathString(pathString);
  local current = addon;

  for _, name in ipairs(pathList) do
    assert(type(current) == 'table', 'Parent namespace is not a table: ' .. name);
    assert(current[name] ~= nil, 'Namespace does not exist: ' .. name);
    current = current[name];
  end

  return current;
end
