local addonName, addon = ...;

local floor = _G.floor;
local log10 = _G.log10;

local geterrorhandler = _G.geterrorhandler;

local UIParent = _G.UIParent;

local IS_RETAIL = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE);
local IS_CLASSIC = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_CLASSIC);
local IS_BC_CLASSIC = (_G.WOW_PROJECT_ID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC);

function addon.isRetail ()
  return IS_RETAIL;
end

function addon.isClassic ()
  return IS_CLASSIC;
end

function addon.isBCClassic ()
  return IS_BC_CLASSIC;
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

function addon.secureCall (callback, ...)
  local success, message = pcall(callback, ...);

  if (not success) then
    geterrorhandler()('error in '.. addonName .. ' plugin: ' .. message);
  end
end
