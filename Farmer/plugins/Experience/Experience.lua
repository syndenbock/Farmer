local addonName, addon = ...;

local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;

local stringJoin = addon.stringJoin;
local truncate = addon.truncate;

local Print = addon.Print;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions').vars
    .farmerOptions.Experience;

local function checkExperienceOptions (info)
  return (options.displayExperience and
          info.percentageGain > options.experienceThreshold);
end

addon.listen('EXPERIENCE_GAINED', function (info)
  if (not checkExperienceOptions(info)) then return end

  Print.printMessage(stringJoin({
    BreakUpLargeNumbers(truncate(info.gain, 1)),
    '(' .. truncate(info.percentageGain, 1) .. '%',
    '/',
    truncate(info.percentage, 1) .. '%)',
  }, ' '), {0.5, 0.5, 1});
end);
