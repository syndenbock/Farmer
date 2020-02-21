local addonName, addon = ...;

local MESSAGE_COLORS = {0, 0.35, 1};

addon:listen('REPUTATION_CHANGED', function (faction, repChange, paragonLevelGained)
  if (farmerOptions.reputation == false or
      addon.Print.checkHideOptions() == false) then
    return;
  end

  local threshold = farmerOptions.reputationThreshold;

  if (paragonLevelGained or abs(repChange) > threshold) then
    if (repChange > 0) then
      repChange = '+' .. repChange;
    end

    if (paragonLevelGained) then
      repChange = repChange ..
          '|TInterface/TargetingFrame/UI-RaidTargetingIcon_1' ..
          addon.vars.iconOffset .. '|t';
    end

    --[[ could have stored faction name when generating faction info, but we
         can afford getting the name now for saving the memory ]]
    local message = GetFactionInfoByID(faction) .. ' ' .. repChange;

    addon.Print.printMessage(message, MESSAGE_COLORS);
  end
end);

