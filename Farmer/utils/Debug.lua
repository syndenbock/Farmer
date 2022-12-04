local _, addon = ...;

local tostring = _G.tostring;
local tinsert = _G.tinsert;

local Debug = addon:extend('Debug', {});
local enabled = false;

local stringifyTable;
local stringifyElement;

stringifyTable = function (table)
  if (next(table) == nil) then
    return '{}';
  end

  local fragments = {};

  for key, value in pairs(table) do
    tinsert(fragments, '  ' .. key .. ' = ' .. stringifyElement(value));
  end

  tinsert(fragments, 1, '{');
  tinsert(fragments, '}');

  return addon.stringJoin(fragments, '\n');
end

stringifyElement = function (element)
  if (type(element) == 'table') then
    return stringifyTable(element);
  else
    return tostring(element);
  end
end

local function printElements (...)
  local elements = {...};
  local strings = {};

  for _, element in ipairs(elements) do
    tinsert(strings, stringifyElement(element));
  end

  addon.printAddonMessage('Debug:', addon.stringJoin(strings, ' '));
end

function Debug.setEnabled (value)
  if (enabled ~= value) then
    enabled = value;
    printElements((enabled and 'enabled' or 'disabled') .. ' debugging');
  end
end

function Debug.print(...)
  if (not enabled) then return end

  printElements(...);
end

function Debug.call (func, ...)
  if (not enabled) then return end

  pcall(func, ...);
end
