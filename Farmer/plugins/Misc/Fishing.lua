local addonName, addon = ...;

local GetCVar = _G.GetCVar;
local SetCVar = _G.SetCVar;
local GetSpellInfo = _G.GetSpellInfo;
local InCombatLockdown = _G.InCombatLockdown;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Misc;

local UNITID_PLAYER = 'player';
local FISHING_NAME = GetSpellInfo(7620);
local HIDE_STATES = {
  off = 0,
  hide = 1,
  hidden = 2,
  restore = 3,
};

local hideState = HIDE_STATES.off;
local platesShown;

local function isUnitPlayer (unit)
  return (unit == UNITID_PLAYER);
end

local function shouldPlatesBeHidden (unit)
  return (options.hidePlatesWhenFishing == true and
          isUnitPlayer(unit) and
          (hideState == HIDE_STATES.off or hideState == HIDE_STATES.restore));
end

local function isSpellFishing (spellid)
  return (GetSpellInfo(spellid) == FISHING_NAME);
end

local function hidePlates ()
  if (platesShown == nil) then
    platesShown = GetCVar('nameplateShowAll');
  end

  SetCVar('nameplateShowAll', 0);
  hideState = HIDE_STATES.hidden;
end

local function restorePlates ()
  if (platesShown ~= nil) then
    SetCVar('nameplateShowAll', platesShown);
    platesShown = nil;
  end

  hideState = HIDE_STATES.off;
end

local function shouldPlatesBeRestored (unit)
  return (isUnitPlayer(unit) and
          (hideState == HIDE_STATES.hidden or hideState == HIDE_STATES.hide));
end

addon.on('UNIT_SPELLCAST_CHANNEL_START', function (unit, _, spellid)
  if (not shouldPlatesBeHidden(unit) or
      not isSpellFishing(spellid)) then
    return;
  end

  if (hideState ~= HIDE_STATES.off and hideState ~= HIDE_STATES.hide) then
    return;
  end

  if (InCombatLockdown()) then
    hideState = HIDE_STATES.hide;
  else
    hidePlates();
  end
end);

addon.on('UNIT_SPELLCAST_CHANNEL_STOP', function (unit)
  if (not shouldPlatesBeRestored(unit)) then return end

  if (InCombatLockdown() == true) then
    hideState = HIDE_STATES.restore;
  else
    restorePlates();
  end
end);

addon.on('PLAYER_REGEN_ENABLED', function ()
  if (hideState == HIDE_STATES.hide) then
    hidePlates();
  elseif (hideState == HIDE_STATES.restore) then
    restorePlates();
  end
end);

addon.on('PLAYER_ENTERING_WORLD', restorePlates);
