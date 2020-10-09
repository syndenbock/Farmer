local addonName, addon = ...;

local floor = _G.floor;
local log10 = _G.log10;

local WOW_PROJECT_ID = _G.WOW_PROJECT_ID;
local WOW_PROJECT_CLASSIC = _G.WOW_PROJECT_CLASSIC;

function addon.isClassic ()
  return WOW_PROJECT_ID == WOW_PROJECT_CLASSIC;
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

function addon.transformFrameAnchorsToCenter (frame)
  local points = {frame:GetPoint()};
  local anchor = points[1];

  if (addon.stringEndsWith(anchor, 'LEFT')) then
    points[4] = points[4] + frame:GetWidth() / 2;
  end

  if (addon.stringEndsWith(anchor, 'RIGHT')) then
    points[4] = points[4] - frame:GetWidth() / 2;
  end

  if (addon.stringStartsWith(anchor, 'TOP')) then
    points[5] = points[5] - frame:GetHeight() / 2;
  end

  if (addon.stringStartsWith(anchor, 'BOTTOM')) then
    points[5] = points[5] + frame:GetHeight() / 2;
  end

  points[1] = 'CENTER';
  frame:ClearAllPoints();
  frame:SetPoint(unpack(points));
end

function addon.printTable (table)
  if (type(table) ~= 'table') then
    print(table);
    return;
  end

  if (not next(table)) then
    print('table is empty');
    return;
  end

  for i,v in pairs(table) do
    print(i, ' - ', v);
  end
end

function addon.secureCall (callback, ...)
  local success, message = pcall(callback, ...);

  if (not success) then
    print('error in', addonName, 'plugin:', message);
  end
end
