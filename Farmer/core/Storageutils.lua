local addonName, addon = ...;

local utils = {};

addon.StorageUtils = utils;

utils.addItem = function (inventory, id, count, linkMap)
  if (type(linkMap) ~= 'table') then
    linkMap = {[linkMap] = true};
  end

  if (inventory[id] == nil) then
    -- saving all links because gear has same ids, but different links
    inventory[id] = {
      links = linkMap,
      count = count,
    };
  else
    local itemInfo = inventory[id];

    itemInfo.count = itemInfo.count + count;

    for link in pairs(linkMap) do
      if (itemInfo.links[link] == nil) then
        itemInfo.links[link] = true;
      end
    end
  end
end
