local addonName, addon = ...;

if (not addon.isDetectorAvailable('experience')) then return end

local strjoin = _G.strjoin;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;

local truncate = addon.truncate;
local printMessageWithData = addon.Print.printMessageWithData;
local farmerFrame = addon.frame;

local SUBSPACE = farmerFrame:CreateSubspace();
local IDENTIFIER = 'experience';
local MESSAGE_COLORS = {r = 0.5, g = 0.5, b = 1};

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
  }, strjoin('',
    BreakUpLargeNumbers(truncate(gain, 1)),
    ' (', truncate(percentageGain, 1), '%',
    '/',
    truncate(info.percentage, 1), '%)'
  ), MESSAGE_COLORS);
end);
