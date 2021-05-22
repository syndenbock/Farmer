local addonName, addon = ...;

if (not addon.isDetectorAvailable('experience')) then return end

local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;

local stringJoin = addon.stringJoin;
local truncate = addon.truncate;

local printMessageWithData = addon.Print.printMessageWithData;
local farmerFrame = addon.frame;

local SUBSPACE = farmerFrame:CreateSubspace();
local IDENTIFIER = 'experience';

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Experience;

local function checkExperienceOptions (info)
  return (options.displayExperience and
          info.percentageGain > options.experienceThreshold);
end

local function determineGains (info)
  local stored = farmerFrame:GetMessageData(SUBSPACE, IDENTIFIER);

  if (stored == nil) then
    return info.gain, info.percentageGain;
  end

  return info.gain + stored.gain, info.percentageGain + stored.percentageGain;
end

addon.listen('EXPERIENCE_GAINED', function (info)
  if (not checkExperienceOptions(info)) then return end

  local gain, percentageGain = determineGains(info);

  printMessageWithData(SUBSPACE, IDENTIFIER, {
    gain = gain,
    percentageGain = percentageGain,
  }, stringJoin({
    BreakUpLargeNumbers(truncate(gain, 1)),
    '(' .. truncate(percentageGain, 1) .. '%',
    '/',
    truncate(info.percentage, 1) .. '%)',
  }, ' '), {0.5, 0.5, 1});
end);
