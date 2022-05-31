local ADDON_NAME, ADDON = ...;

local tinsert = _G.tinsert;

local SCANNING_TOOLTIP = _G.CreateFrame('GameTooltip',
    ADDON_NAME .. 'ScannerTooltip', nil, 'GameTooltipTemplate');
local TOOLTIP_NAME = SCANNING_TOOLTIP:GetName();

SCANNING_TOOLTIP:SetOwner(_G.WorldFrame, 'ANCHOR_NONE');

local scanner = ADDON:extend('TooltipScanner', {});

local function getTooltipLinesByNames ()
  local lines = {};

  for x = 1, SCANNING_TOOLTIP:NumLines(), 1 do
    local line = _G[TOOLTIP_NAME .. 'TextLeft' .. x];
    local text = line and line:GetText();

    if (text ~= nil) then
      tinsert(lines, line:GetText());
    end
  end

  return lines;
end

local function getTooltipLinesByRegions ()
  local regions = {SCANNING_TOOLTIP:GetRegions()};
  local lines = {};

  for index, region in ipairs(regions) do
    if (region:GetObjectType() == 'FontString') then
      local text = region:GetText();

      if (text ~= nil) then
        tinsert(lines, text);
      end
    end
  end

  return lines;
end

function scanner.getLinesByItemLink (itemLink)
  SCANNING_TOOLTIP:ClearLines();
  SCANNING_TOOLTIP:SetHyperlink(itemLink);

  return getTooltipLinesByNames();
end
