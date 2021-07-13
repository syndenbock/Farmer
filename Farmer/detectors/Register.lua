local _, addon = ...;

local availableDetectors = {};
local unavailableDetectors = {};

local function isDetectorKnown (detectorName)
  return (availableDetectors[detectorName] ~= nil or
      unavailableDetectors[detectorName] ~= nil);
end

function addon.registerAvailableDetector (detectorName, data)
  assert(not isDetectorKnown(detectorName),
      addon.createAddonMessage('detector was already registered: ' ..
      detectorName));

  if (data == nil) then
    data = true;
  end

  availableDetectors[detectorName] = data;
end

function addon.registerUnavailableDetector (detectorName)
  assert(not isDetectorKnown(detectorName),
      addon.createAddonMessage('detector was already registered: ' ..
      detectorName));
  unavailableDetectors[detectorName] = true;
end

function addon.isDetectorAvailable (detectorName)
  assert(isDetectorKnown(detectorName),
      addon.createAddonMessage('unknown detector: ' .. detectorName));

  return (availableDetectors[detectorName] ~= nil);
end
