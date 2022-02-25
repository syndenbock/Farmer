local _, addon = ...;

addon.registerAvailableDetector('experience');

local UnitXP = _G.UnitXP;
local UnitXPMax = _G.UnitXPMax;

local ImmutableMap = addon.Factory.ImmutableMap;

local UNIT_PLAYER = 'player';

local currentExperience;
local currentLevelupExperience;

local function yellExperience (info)
  addon.yell('EXPERIENCE_GAINED', ImmutableMap(info));
end

local function checkExperience ()
  local newExperience = UnitXP(UNIT_PLAYER);
  local gain = newExperience - currentExperience;
  local levelUp = false;

  if (currentLevelupExperience == nil) then
    levelUp = true;
    currentLevelupExperience = UnitXPMax(UNIT_PLAYER);
  end

  currentExperience = newExperience;

  if (gain <= 0) then
    return;
  end

  local percentageGain = gain * 100 / currentLevelupExperience;
  local currentPercentage = currentExperience * 100 / currentLevelupExperience;

  yellExperience({
    current = currentExperience,
    percentage = currentPercentage,
    nextLevel = currentLevelupExperience,
    gain = gain,
    percentageGain = percentageGain,
    levelUp = levelUp,
  });
end

addon.onOnce('PLAYER_LOGIN', function ()
  currentExperience = UnitXP(UNIT_PLAYER);
  currentLevelupExperience = UnitXPMax(UNIT_PLAYER)
end);

addon.on('PLAYER_LEVEL_UP', function ()
  --[[ Experience resets each levelup, so it's set to the negative of the value
    that was last needed for a levelup so it's valued in on the upcoming
    PLAYER_XP_UPDATE event ]]
  currentExperience = currentExperience - currentLevelupExperience;
  --[[ The experience needed for the next levelup is not available yet, so it's
    set to nil to the next experience check reads it ]]
  currentLevelupExperience = nil;
end);

addon.funnel('PLAYER_XP_UPDATE', checkExperience);
