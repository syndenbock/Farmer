local _, addon = ...;

local farmerFrame = _G.CreateFrame('MessageFrame', 'farmerFrame', _G.UIParent);
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
farmerFrame:SetFadeDuration(0.5);
farmerFrame:SetInsertMode('TOP');
farmerFrame:SetFontObject(font);
farmerFrame:SetJustifyV('MIDDLE');
farmerFrame:SetJustifyH('CENTER');
addon.setTrueScale(farmerFrame, 1);
farmerFrame:Show();
