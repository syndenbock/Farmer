local _, addon = ...;

-- local farmerFrame = _G.CreateFrame('ScrollingMessageFrame', 'farmerFrame', _G.UIParent);

local farmerFrame = addon.Widget.MessageFrame:New();

addon.frame = farmerFrame;

-- farmerFrame:SetWidth(_G.GetScreenWidth() / 2);
-- farmerFrame:SetHeight(_G.GetScreenHeight() / 2);

-- farmerFrame:SetFrameStrata('DIALOG');
-- farmerFrame:SetFrameStrata('FULLSCREEN_DIALOG');
-- farmerFrame:SetFrameStrata('TOOLTIP');
-- farmerFrame:SetFrameLevel(2);
-- farmerFrame:SetFading(true);
farmerFrame:SetFadeDuration(0.5);
farmerFrame:SetSpacing(0);
-- farmerFrame:SetJustifyV('MIDDLE');
farmerFrame:SetJustifyH('CENTER');
-- addon.setTrueScale(farmerFrame, 1);
-- farmerFrame:Show();
