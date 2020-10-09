local _, addon = ...;

local farmerFrame = addon.Widget.MessageFrame:New('farmerFrame');

addon.frame = farmerFrame;

-- farmerFrame:SetFrameStrata('BACKGROUND');
-- farmerFrame:SetFrameStrata('DIALOG');
-- farmerFrame:SetFrameStrata('FULLSCREEN_DIALOG');
farmerFrame:SetFrameStrata('TOOLTIP');
farmerFrame:SetFrameLevel(2);
farmerFrame:SetFading(true);
farmerFrame:SetFadeDuration(0.5);
