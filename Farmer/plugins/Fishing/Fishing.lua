local addonName, addon = ...;

local UNITID_PLAYER = 'player';
local FISHING_NAME = GetSpellInfo(7620);
local platesShown;
local fishingFlag = false;
local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars;

local function restorePlates ()
  if (platesShown ~= nil) then
    SetCVar('nameplateShowAll', platesShown);
    --[[ we change platesShown back to nil, so when someone disables the
    option and changes nameplates manually, the old value does not get
    applied anymore --]]
    platesShown = nil;
  end
end

addon:on('UNIT_SPELLCAST_CHANNEL_START', function(unit, target, spellid)
  if (saved.farmerOptions.hidePlatesWhenFishing ~= true or
      unit ~= UNITID_PLAYER or
      InCombatLockdown() == true) then
    return
  end

  local spellName = GetSpellInfo(spellid);

  if (spellName == FISHING_NAME) then
    platesShown = GetCVar('nameplateShowAll');
    SetCVar('nameplateShowAll', 0);
  end
end);

addon:on('PLAYER_REGEN_ENABLED', function()
  if (fishingFlag == true) then
    restorePlates();
    fishingFlag = false;
  end
end);

addon:on('UNIT_SPELLCAST_CHANNEL_STOP', function(unit, target, spellid)
  if (unit ~= UNITID_PLAYER or platesShown == nil) then
    return
  end

  if (InCombatLockdown() == true) then
    fishingFlag = true;
  else
    restorePlates();
  end
end);

addon:on('PLAYER_ENTERING_WORLD', restorePlates);
