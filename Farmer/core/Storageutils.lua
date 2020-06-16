local addonName, addon = ...;

local utils = {};

addon.StorageUtils = utils;

utils.addItem = function (inventory, id, count, linkMap)
  -- This is the main inventory handling function and gets called a lot.
  -- Therefor, performance has priority over code shortage.
  local itemInfo = inventory[id];

  if (type(linkMap) ~= 'table') then
    linkMap = {[linkMap] = count};
  end

  if (not itemInfo) then
    -- it's important to create a new object without copying references to avoid
    -- manipulating the origin linkMap when updating the inventory afterwards
    local links = {};

    for link, linkCount in pairs(linkMap) do
      links[link] = linkCount;
    end

    inventory[id] = {
      count = count,
      links = links,
    };

    return;
  end

  local links = itemInfo.links;

  itemInfo.count = itemInfo.count + count;

  -- saving all links because gear has same ids, but different links
  for link, linkCount in pairs(linkMap) do
    links[link] = (links[link] or 0) + linkCount;
  end
end
