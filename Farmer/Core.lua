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

local function share (pathList)
  local current = addon;

  for _, name in ipairs(pathList) do
    if (current[name] == nil) then
      current[name] = {};
    end

    current = current[name];
  end

  return current;
end

local function splitPathString (pathString)
  return {strsplit('/', pathString)};
end

function addon.share (pathString)
  return share(splitPathString(pathString));
end

function addon.export (pathString, value)
  assert(value ~= nil, 'Export value is nil');

  local pathList = splitPathString(pathString);
  local name = tremove(pathList);
  local shared = share(pathList);

  assert(shared[name] == nil, 'Value already exists: ' .. name);

  shared[name] = value;

  return value;
end

function addon.import (pathString)
  local pathList = splitPathString(pathString);
  local current = addon;

  for _, name in ipairs(pathList) do
    assert(current[name] ~= nil, 'Module does not exist: ' .. name);
    current = current[name];
  end

  return current;
end
