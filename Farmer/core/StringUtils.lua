local _, addon = ...;

local strfind = _G.strfind;
local strsub = _G.strsub;

function addon.stringStartsWith (string, check)
  return (string:sub(1, #check) == check);
end

function addon.stringEndsWith (string, check)
  return (check == "" or string:sub(-#check) == check);
end

function addon.stringJoin (stringList, joiner)
  joiner = joiner or '';
  local result;

  for _, fragment in pairs(stringList) do
    if (fragment) then
      result = result and result .. joiner .. fragment or fragment;
    end
  end

  return result or '';
end

function addon.replaceString (string, match, replacement)
  local startPos, endPos = strfind(string, match, 1, true);

  if (startPos) then
    return strsub(string, 1, startPos - 1) .. replacement .. strsub(string, endPos + 1);
  else
    return string;
  end
end
