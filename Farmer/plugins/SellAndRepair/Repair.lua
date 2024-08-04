local addonName, addon = ...;

local EventUtils = addon.import('Utils/Events');

local CanMerchantRepair = _G.CanMerchantRepair;
local GetRepairAllCost = _G.GetRepairAllCost;
local IsInGuild = _G.IsInGuild;
local CanGuildBankRepair = _G.CanGuildBankRepair;
local GetGuildBankWithdrawMoney = _G.GetGuildBankWithdrawMoney;
local RepairAllItems = _G.RepairAllItems;
local GetMoney = _G.GetMoney;

local MERCHANT_INTERACTION_TYPE = _G.Enum.PlayerInteractionType.Merchant;

local L = addon.L;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.SellAndRepair;

local function repairEquipmentFromGuildFunds (cost)
  RepairAllItems(true);
  print(L['Equipment has been repaired by your guild for %s']
      :format(addon.formatMoney(cost)));
end

local function canGuildRepair (cost)
  if (not IsInGuild() or
      not CanGuildBankRepair or not CanGuildBankRepair() or
      options.autoRepairAllowGuild ~= true) then
    return false;
  end

  -- Can not check actual guild money because GetGuildMoney() returns 0
  -- if guild bank frame was not opened yet
  return (GetGuildBankWithdrawMoney() >= cost);
end

local function performGuildRepair (cost)
  if (canGuildRepair(cost)) then
    repairEquipmentFromGuildFunds(cost);
    return true;
  end

  return false;
end

local function repairEquipmentFromOwnFunds (cost)
  RepairAllItems(false);
  print(L['Equipment has been repaired for %s']
      :format(addon.formatMoney(cost)));
end

local function canSelfRepair (cost)
  return (cost <= GetMoney());
end

local function performSelfRepair (cost)
  if (canSelfRepair(cost)) then
    repairEquipmentFromOwnFunds(cost);
    return true;
  end

  return false;
end

local function repairEquipment ()
  local repairAllCost, canRepair = GetRepairAllCost();

  if (not canRepair) then return end

  if (not (performGuildRepair(repairAllCost) or
           performSelfRepair(repairAllCost))) then
    print(L['Not enough gold for repairing your gear']);
  end
end

local function shouldAutoRepair ()
  return (CanMerchantRepair() and options.autoRepair == true);
end

EventUtils.onInteractionFrameShow(MERCHANT_INTERACTION_TYPE, function ()
  if (shouldAutoRepair()) then
    repairEquipment();
  end
end);
