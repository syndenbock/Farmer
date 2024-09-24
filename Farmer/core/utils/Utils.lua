local _, addon = ...;

local floor = _G.floor;
local log10 = _G.log10;

local UIParent = _G.UIParent;

local module = addon.export('core/utils/Utils', {});

local IS_RETAIL = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE);
local IS_CLASSIC = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC);
local IS_BC_CLASSIC = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC);
local IS_WRATH_CLASSIC = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_WRATH_CLASSIC);
local IS_CATA_CLASSIC = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CATACLYSM_CLASSIC);

function module.isRetail ()
  return IS_RETAIL;
end

function module.isClassic ()
  return IS_CLASSIC;
end

function module.isBCClassic ()
  return IS_BC_CLASSIC;
end

function module.isWrathClassic ()
  return IS_WRATH_CLASSIC;
end

function module.isCataClassic ()
  return IS_CATA_CLASSIC;
end

function module.round (number)
  return floor(number + 0.5);
end

function module.toStepPrecision (value, stepSize)
  if (stepSize == 1) then
    return module.round(value);
  end

  return module.round(value / stepSize) * stepSize;
end

function module.stepSizeToPrecision (stepSize)
  if (stepSize == 1) then
    return 0;
  end

  -- step sizes received from sliders are slightly off the actual value, so
  -- round has to be used
  return module.round(log10(1 / stepSize));
end

function module.truncate (number, digits)
  if (digits == 0) then
    return module.round(number);
  end

  local factor = 10 ^ digits;

  number = number * factor;
  number = module.round(number);
  number = number / factor;

  return number;
end

function module.findGlobal (...)
  local global = _G;

  for x = 1, select('#', ...), 1 do
    global = global[select(x, ...)];

    if (global == nil) then
      return nil;
    end
  end

  return global;
end

function module.readOptions (defaults, options, newOptions)
  options = options or {};
  newOptions = newOptions or {};

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

function module.getFrameRelativeCoords (frame, anchorFrame)
  anchorFrame = anchorFrame or UIParent;

  local points = getFrameCenteredCoords(frame);
  local anchorPoints = getFrameCenteredCoords(anchorFrame);

  return {
    x = (points.x - anchorPoints.x) / frame:GetEffectiveScale(),
    y = (points.y - anchorPoints.y) / frame:GetEffectiveScale(),
  };
end

function module.transformFrameAnchorsToCenter (frame, anchorFrame)
  anchorFrame = anchorFrame or UIParent;

  local relativePoints = module.getFrameRelativeCoords(frame, anchorFrame);

  frame:ClearAllPoints();
  frame:SetPoint('CENTER', anchorFrame, 'CENTER', relativePoints.x,
      relativePoints.y);
end

function module.measure (callback, ...)
  local stamp = _G.debugprofilestop();
  local result = {callback(...)};
  print(_G.debugprofilestop() - stamp)
  return unpack(result);
end

function module.createMeasureWrapper (callback)
  return function (...)
    return module.measure(callback, ...);
  end
end
