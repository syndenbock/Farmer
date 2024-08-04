local addonName, addon = ...;

local floor = _G.floor;
local log10 = _G.log10;

local UIParent = _G.UIParent;

local IS_RETAIL = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE);
local IS_CLASSIC = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC);
local IS_BC_CLASSIC = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC);
local IS_WRATH_CLASSIC = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC);
local IS_CATA_CLASSIC = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CATACLYSM_CLASSIC);

function addon.isRetail ()
  return IS_RETAIL;
end

function addon.isClassic ()
  return IS_CLASSIC;
end

function addon.isBCClassic ()
  return IS_BC_CLASSIC;
end

function addon.isWrathClassic ()
  return IS_WRATH_CLASSIC;
end

function addon.isCataClassic ()
  return IS_CATA_CLASSIC;
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

function addon.findGlobal (...)
  local global = _G;

  for x = 1, select('#', ...), 1 do
    global = global[select(x, ...)];

    if (global == nil) then
      return nil;
    end
  end

  return global;
end

function addon.readOptions (defaults, options, newOptions)
  newOptions = newOptions or {};
  options = options or {};

  for option, default in pairs(defaults) do
    if (type(default) == type(options[option])) then
      newOptions[option] = options[option];
    else
      newOptions[option] = default;
    end
  end

  return newOptions;
end

local function getFrameCenteredCoords (frame)
  local points = {frame:GetCenter()};

  return {
    x = points[1] * frame:GetEffectiveScale(),
    y = points[2] * frame:GetEffectiveScale(),
  };
end

function addon.getFrameRelativeCoords (frame, anchorFrame)
  anchorFrame = anchorFrame or UIParent;

  local points = getFrameCenteredCoords(frame);
  local anchorPoints = getFrameCenteredCoords(anchorFrame);

  return {
    x = (points.x - anchorPoints.x) / frame:GetEffectiveScale(),
    y = (points.y - anchorPoints.y) / frame:GetEffectiveScale(),
  };
end

function addon.transformFrameAnchorsToCenter (frame, anchorFrame)
  anchorFrame = anchorFrame or UIParent;

  local relativePoints = addon.getFrameRelativeCoords(frame, anchorFrame);

  frame:ClearAllPoints();
  frame:SetPoint('CENTER', anchorFrame, 'CENTER', relativePoints.x,
      relativePoints.y);
end

function addon.measure (callback, ...)
  local stamp = _G.debugprofilestop();
  local result = {callback(...)};
  print(_G.debugprofilestop() - stamp)
  return unpack(result);
end

function addon.createMeasureWrapper (callback)
  return function (...)
    return addon.measure(callback, ...);
  end
end
