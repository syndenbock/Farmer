local addonName, addon = ...;

local utils = {};

addon.StorageUtils = utils;

utils.addItem = function (inventory, id, count, linkMap)
  local itemInfo = inventory[id];

  if (type(linkMap) ~= 'table') then
    linkMap = {[linkMap] = count};
  end

  if (not itemInfo) then
    -- saving all links because gear has same ids, but different links
    inventory[id] = {
      links = linkMap,
      count = count,
    };
  else
    local links = itemInfo.links;

    itemInfo.count = itemInfo.count + count;

    for link in pairs(linkMap) do
      links[link] = (links[link] or 0) + count;
    end
  end
end
