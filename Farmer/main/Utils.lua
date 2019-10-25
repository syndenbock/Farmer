local addonName, addon = ...;

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

function addon:getIcon (texture)
  return addon:stringJoin({'|T', texture, addon.vars.iconOffset, '|t'}, '');
end

function addon:printTable (table)
  for i,v in pairs(table) do
    print(i, ' - ', v)
  end
end
