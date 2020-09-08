local _, addon = ...;

local farmerFrame = _G.CreateFrame('ScrollingMessageFrame', 'farmerFrame', _G.UIParent);
local font = _G.CreateFont('farmerFont');

addon.frame = farmerFrame;
addon.font = font;

farmerFrame:SetWidth(_G.GetScreenWidth() / 2);
farmerFrame:SetHeight(_G.GetScreenHeight() / 2);

-- farmerFrame:SetFrameStrata('DIALOG');
-- farmerFrame:SetFrameStrata('FULLSCREEN_DIALOG');
farmerFrame:SetFrameStrata('TOOLTIP');
farmerFrame:SetFrameLevel(2);
farmerFrame:SetFading(true);
-- farmerFrame:SetTimeVisible(2);
farmerFrame:SetFadeDuration(0.5);
farmerFrame:SetMaxLines(20);
farmerFrame:SetInsertMode('TOP');
farmerFrame:SetFontObject(font);
addon.setTrueScale(farmerFrame, 1);
farmerFrame:Show();
