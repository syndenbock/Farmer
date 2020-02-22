local addonName, addon = ...;

addon:slash('test', function (id, count)
  print(addon:formatNumber(1500));
  print(addon:formatNumber(15357));
  addon:yell('CURRENCY_CHANGED', 1755, 1500, 15357);

  if (true) then return end

  if (id ~= nil) then
    local _, link = GetItemInfo(id);
    count = tonumber(count or 1);
    addon:yell('NEW_ITEM', link, id, count);
    return;
  end

  local testItems = {
    2447, -- Peacebloom
    4496, -- Small Brown Pouch
    6975, -- Whirlwind Axe
    4322, -- Enchanter's Cowl
    13521, -- Recipe: Flask of Supreme Power
  };

  for i = 1, #testItems, 1 do
    local id = testItems[i];
    local _, link = GetItemInfo(id);

    addon:yell('NEW_ITEM', link, id, 1);
    addon:yell('NEW_ITEM', link, id, 4);
  end
end);
