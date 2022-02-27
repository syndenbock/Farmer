local _, addon = ...;

local availableDetectors = {};
local unavailableDetectors = {};

local function isDetectorKnown (detectorName)
  return (availableDetectors[detectorName] ~= nil or
      unavailableDetectors[detectorName] ~= nil);
end

addon.export('registerAvailableDetector', function (detectorName)
  assert(not isDetectorKnown(detectorName),
      addon.createAddonMessage('detector was already registered: ' ..
      detectorName));

  availableDetectors[detectorName] = true;
end);

addon.export('registerUnavailableDetector', function (detectorName)
  assert(not isDetectorKnown(detectorName),
      addon.createAddonMessage('detector was already registered: ' ..
      detectorName));
  unavailableDetectors[detectorName] = true;
end);

addon.export('isDetectorAvailable', function (detectorName)
  assert(isDetectorKnown(detectorName),
      addon.createAddonMessage('unknown detector: ' .. detectorName));

  return (availableDetectors[detectorName] ~= nil);
end);
