local _, addon = ...;

local C_Container = _G.C_Container or {};

local function GetContainerItemInfo (containerIndex, slotIndex)
  -- Use GetContainerItemID because GetContainerItemInfo returns nil if item
  -- data is not ready yet
  local itemID = _G.GetContainerItemID(containerIndex, slotIndex);

  if (itemID) then
    local info = {_G.GetContainerItemInfo(containerIndex, slotIndex)};

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

addon.export('polyfills/C_Container', {
  ContainerIDToInventoryID = C_Container.ContainerIDToInventoryID or _G.ContainerIDToInventoryID,
  GetContainerNumFreeSlots = C_Container.GetContainerNumFreeSlots or GetContainerNumFreeSlots,
  GetContainerNumSlots = C_Container.GetContainerNumSlots or _G.GetContainerNumSlots,
  UseContainerItem = C_Container.UseContainerItem or _G.UseContainerItem,
  GetContainerItemInfo = C_Container.GetContainerItemInfo or GetContainerItemInfo,
});
