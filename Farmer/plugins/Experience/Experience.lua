local addonName, addon = ...;

if (not addon.isDetectorAvailable('experience')) then return end

local strconcat = _G.strconcat;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;

local Yell = addon.import('core/logic/Yell');
local Utils = addon.import('core/utils/Utils');
local SavedVariables = addon.import('client/utils/SavedVariables');
local Main = addon.import('main/Main');
local Print = addon.import('main/Print');

local truncate = Utils.truncate;
local printMessageWithData = Print.printMessageWithData;

local SUBSPACE = Main.frame:CreateSubspace();
local IDENTIFIER = 'experience';
local MESSAGE_COLORS = {r = 0.5, g = 0.5, b = 1};

local options =
    SavedVariables.SavedVariablesHandler(addonName, 'farmerOptions').vars.farmerOptions.Experience;

local function checkExperienceOptions (info)
  return (options.displayExperience and
          info.percentageGain > options.experienceThreshold);
end

local function determineGains (info)
  local stored = Main.frame:GetMessageData(SUBSPACE, IDENTIFIER);

  if (stored == nil) then
    return info.gain, info.percentageGain;
  end

  return info.gain + stored.gain, info.percentageGain + stored.percentageGain;
end

Yell.listen('EXPERIENCE_GAINED', function (info)
  if (not checkExperienceOptions(info)) then return end

  local gain, percentageGain = determineGains(info);

  printMessageWithData(SUBSPACE, IDENTIFIER, {
    gain = gain,
    percentageGain = percentageGain,
  }, strconcat(
    BreakUpLargeNumbers(truncate(gain, 1)),
    ' (', truncate(percentageGain, 1), '%',
    '/',
    truncate(info.percentage, 1), '%)'
  ), MESSAGE_COLORS);
end);
