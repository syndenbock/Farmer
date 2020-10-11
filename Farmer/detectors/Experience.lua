local _, addon = ...;

local UnitXP = _G.UnitXP;
local UnitXPMax = _G.UnitXPMax;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;

local truncate = addon.truncate;

local UNIT_PLAYER = 'player';

local currentExperience;
local currentLevelupExperience;

local function checkExperience ()
  local newExperience = UnitXP(UNIT_PLAYER);
  local difference = newExperience - currentExperience;

  currentLevelupExperience = currentLevelupExperience or UnitXPMax(UNIT_PLAYER);
  currentExperience = newExperience;

  if (difference <= 0) then
    -- print('no xp gain: ', difference);
    return;
  end

  local percentage = truncate(difference * 100 / currentLevelupExperience, 1);

  -- print(truncate(currentExperience * 100 / currentLevelupExperience, 1));

  addon.frame:AddMessage(addon.stringJoin({
    'experience:', BreakUpLargeNumbers(difference), '(' .. percentage .. '%)',
  }, ' '));
end

addon.on('PLAYER_LOGIN', function ()
  currentExperience = UnitXP(UNIT_PLAYER);
  currentLevelupExperience = UnitXPMax(UNIT_PLAYER)
end);

addon.on('PLAYER_LEVEL_UP', function ()
  --[[ Experience resets each levelup, so it's to the negative of the value
    that was last needed for a levelup so it is valued in on the upcoming
    PLAYER_XP_UPDATE event ]]
  currentExperience = currentExperience -currentLevelupExperience;
  --[[ The experience needed for the next levelup is not available yet, so it's
    set to nil to the next experience check reads it ]]
  currentLevelupExperience = nil;
end);

addon.on('PLAYER_XP_UPDATE', function (unit)
  if (unit ~= UNIT_PLAYER) then return end

  checkExperience();
end);
