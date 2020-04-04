local addonName, addon = ...;

local WOW_PROJECT_ID = _G.WOW_PROJECT_ID;
local WOW_PROJECT_CLASSIC = _G.WOW_PROJECT_CLASSIC;
local unpack = _G.unpack;
local strsub = _G.strsub;
local strlen = _G.strlen;

function addon:isClassic ()
  return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC;
end

function addon:stringJoin (stringList, joiner)
  joiner = joiner or '';
  local result = nil;

  for index, fragment in pairs(stringList) do
    if (fragment ~= nil) then
      if (result == nil) then
        result = fragment;
      else
        result = result .. joiner .. fragment;
      end
    end
  end

  return result or '';
end

function addon:formatNumber (number, stepSize, separator)
  assert(type(number) == 'number', 'argument is not a number');

  stepSize = stepSize or 3;
  separator = separator or ',';

  number = tostring(number);

  -- this check improves performance because it can prevent unnecessary array
  -- operations
  if (strlen(number) <= stepSize) then
    return number;
  end

  local fragments = {};

  repeat
    local fragment = strsub(number, -stepSize);

    number = strsub(number, 1, -stepSize - 1);
    table.insert(fragments, 1, fragment);
  until (strlen(number) <= stepSize)

  table.insert(fragments, 1, number);

  return addon:stringJoin(fragments, separator);
end


function addon:getIcon (texture)
  return addon:stringJoin({'|T', texture, addon.vars.iconOffset, '|t'}, '');
end

function addon:printTable (table)
  if (type(table) ~= 'table') then
    print(table);
    return;
  end

  if (next(table) == nil) then
    print('table is empty');
    return;
  end

  for i,v in pairs(table) do
    print(i, ' - ', v);
  end
end

function addon:waitForCallbacks (callbackList, callback)
  local count = #callbackList;

  if (count == 0) then
    callback();
    return;
  end

  local results = {};

  --[[ make sure to not use count for iterating, because if a callback is
       synchroneous it would modify the iteration variable ]]

  for x = 1, #callbackList, 1 do
    callbackList[x](function (result)
      results[x] = result;
      count = count - 1;

      if (count == 0) then
        callback(results);
      end
    end);
  end
end

function addon:bindParams (func, ...)
  local params = {...};

  return function (...)
    func(unpack(params), ...);
  end
end
