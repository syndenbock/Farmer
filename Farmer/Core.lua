local addonName, addon = ...;

local strsplit = _G.strsplit;
local tremove = _G.tremove;

local proxy = {};

setmetatable(addon, {
  __metatable = false,
  __index = proxy,
  __newindex = function (_, key, value)
    assert(proxy[key] == nil,
        addonName .. ': addon key already in use: ' .. key);

    proxy[key] = value;
  end,
});

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

function addon.export (pathString, value)
  assert(value ~= nil, 'Export value is nil');

  local pathList = splitPathString(pathString);
  local name = tremove(pathList);
  local shared = generateNameSpaces(pathList);

  assert(shared[name] == nil, 'Value already exists: ' .. name);

  shared[name] = value;

  return value;
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
