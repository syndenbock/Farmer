local addonName, addon = ...;

local floor = _G.floor;
local log10 = _G.log10;

local WOW_PROJECT_ID = _G.WOW_PROJECT_ID;
local WOW_PROJECT_CLASSIC = _G.WOW_PROJECT_CLASSIC;

function addon.isClassic ()
  return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC;
end

function addon.cloneTable (table)
  local copy = {};

  for key, value in pairs(table) do
    copy[key] = value;
  end

  return copy;
end

function addon.round (number)
  return floor(number + 0.5);
end

function addon.toStepPrecision (value, stepSize)
  if (stepSize == 1) then
    return addon.round(value);
  end

  return addon.round(value / stepSize) * stepSize;
end

function addon.stepSizeToPrecision (stepSize)
  if (stepSize == 1) then
    return 0;
  end

  -- step sizes received from sliders are slightly off the actual value, so
  -- round has to be used
  return addon.round(log10(1 / stepSize));
end

function addon.truncate (number, digits)
  if (digits == 0) then
    return addon.round(number);
  end

  local factor = 10 ^ digits;

  number = number * factor;
  number = addon.round(number);
  number = number / factor;

  return number;
end

function addon.setTrueScale (frame, scale)
  frame:SetScale(1);
  frame:SetScale(scale / frame:GetEffectiveScale());
end

function addon.getFrameRelativeCoords (frame, anchorFrame)
  anchorFrame = anchorFrame or _G.UIParent;

  local points = {frame:GetCenter()};
  local anchorPoints = {anchorFrame:GetCenter()};

  return {
    x = points[1] - anchorPoints[1],
    y = points[2] - anchorPoints[2],
  };
end

function addon.transformFrameAnchorsToCenter (frame, anchorFrame)
  anchorFrame = anchorFrame or _G.UIParent;

  local relativePoints = addon.getFrameRelativeCoords(frame, anchorFrame);

  frame:ClearAllPoints();
  frame:SetPoint('CENTER', anchorFrame, 'CENTER', relativePoints.x,
      relativePoints.y);
end

function addon.secureCall (callback, ...)
  local success, message = pcall(callback, ...);

  if (not success) then
    print('error in', addonName, 'plugin:', message);
  end
end
