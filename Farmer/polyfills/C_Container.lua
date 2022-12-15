local _, addon = ...;

if (C_Container) then
  addon.export('polyfills/C_Container', C_Container);
  return;
end

local GetContainerItemID = _G.GetContainerItemID;
local GetContainerItemInfo = _G.GetContainerItemInfo;

local module = addon.export('polyfills/C_Container', {
  ContainerIDToInventoryID = _G.ContainerIDToInventoryID,
  GetContainerNumFreeSlots = GetContainerNumFreeSlots,
  GetContainerNumSlots = _G.GetContainerNumSlots,
  UseContainerItem = _G.UseContainerItem,
});

function module.GetContainerItemInfo (containerIndex, slotIndex)
  -- Use GetContainerItemID because GetContainerItemInfo returns nil if item
  -- data is not ready yet
  local itemID = GetContainerItemID(containerIndex, slotIndex);

  if (itemID) then
    local info = {GetContainerItemInfo(containerIndex, slotIndex)};

    return {
      iconFileID = info[1],
      stackCount = info[2],
      isLocked = info[3],
      quality = info[4],
      isReadable = info[5],
      hasLoot = info[6],
      hyperlink = info[7],
      isFiltered = info[8],
      hasNoValue = info[9],
      itemID = itemID,
      isBound = info[11],
    };
  end
end
