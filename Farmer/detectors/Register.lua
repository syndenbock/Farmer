local _, addon = ...;

local Strings = addon.import('core/utils/Strings');

local availableDetectors = {};
local unavailableDetectors = {};

local function isDetectorKnown (detectorName)
  return (availableDetectors[detectorName] ~= nil or
      unavailableDetectors[detectorName] ~= nil);
end

function addon.registerAvailableDetector (detectorName)
  assert(not isDetectorKnown(detectorName),
      Strings.createAddonMessage('detector was already registered: ' ..
      detectorName));

  availableDetectors[detectorName] = true;
end

function addon.registerUnavailableDetector (detectorName)
  assert(not isDetectorKnown(detectorName),
      Strings.createAddonMessage('detector was already registered: ' ..
      detectorName));
  unavailableDetectors[detectorName] = true;
end

function addon.isDetectorAvailable (detectorName)
  assert(isDetectorKnown(detectorName),
      Strings.createAddonMessage('unknown detector: ' .. detectorName));

  return (availableDetectors[detectorName] ~= nil);
end
