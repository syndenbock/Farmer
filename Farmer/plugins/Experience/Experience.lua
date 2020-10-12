local _, addon = ...;

local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;

local stringJoin = addon.stringJoin;
local truncate = addon.truncate;

local farmerFrame = addon.frame;

addon.listen('EXPERIENCE_GAINED', function (info)
  farmerFrame:AddMessage(stringJoin({
    'experience:',
    BreakUpLargeNumbers(truncate(info.gain, 1)),
    '(' .. truncate(info.percentageGain, 1) .. '%',
    '/',
    truncate(info.percentage, 1) .. '%)',
  }, ' '));
end);
