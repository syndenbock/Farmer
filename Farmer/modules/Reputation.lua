local addonName, addon = ...;

local MESSAGE_COLORS = {0, 0.35, 1};

addon:listen('REPUTATION_CHANGED', function (faction, repChange, paragonLevelGained)
  if (farmerOptions.reputation == false or
      addon.Print.checkHideOptions() == false) then
    return;
  end

  local threshold = farmerOptions.reputationThreshold;
  local text = addon:formatNumber(repChange);

  if (paragonLevelGained or abs(repChange) > threshold) then
    if (repChange > 0) then
      text = '+' .. text;
    end

    if (paragonLevelGained) then
      text = text ..
          '|TInterface/TargetingFrame/UI-RaidTargetingIcon_1' ..
          addon.vars.iconOffset .. '|t';
    end

    --[[ could have stored faction name when generating faction info, but we
         can afford getting the name now for saving the memory ]]
    text = GetFactionInfoByID(faction) .. ' ' .. text;

    addon.Print.printMessage(text, MESSAGE_COLORS);
  end
end);

