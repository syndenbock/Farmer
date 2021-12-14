local _, addon = ...;

local CreateFrame = _G.CreateFrame;
local CreateFromMixins = _G.CreateFromMixins;

local Factory = addon.share('Factory');

local Tooltip = {};

Factory.Tooltip = Tooltip;

local tooltipCount = 0;

local function createTooltipName ()
  tooltipCount = tooltipCount + 1;

  return 'FarmerTooltip' .. tooltipCount;
end

local function addTooltipLines (tooltip, lines)
  for _, line in ipairs(lines) do
    tooltip:AddLine(line);
  end
end

local function createTooltip (parent, text)
  local tooltip = CreateFrame('GameTooltip', createTooltipName(), nil,
      'GameTooltipTemplate');

  if (type(text) ~= 'table') then
    text = {text};
  end

  parent:HookScript('OnEnter', function ()
    tooltip:SetOwner(parent, 'ANCHOR_NONE');
    tooltip:SetPoint('BOTTOMLEFT', parent, 'TOPLEFT', 0, 0);

    addTooltipLines(tooltip, text);

    tooltip:Show();
  end);

  parent:HookScript('OnLeave', function ()
    tooltip:Hide();
  end);

  return tooltip;
end

function Tooltip:new (parent, text)
  local this = CreateFromMixins(Tooltip);

  this.tooltip = createTooltip(parent, text);

  return this;
end
