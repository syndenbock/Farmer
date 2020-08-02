local _, addon = ...;

local Factory = addon.share('Factory');

local Tooltip = {};

Factory.Tooltip = Tooltip;

Tooltip.__index = Tooltip;

local tooltipCount = 0;

local function createTooltipName ()
  tooltipCount = tooltipCount + 1;

  return 'FarmerTooltip' .. tooltipCount;
end

local function createTooltip (parent, text)
  local tooltip = CreateFrame('GameTooltip', createTooltipName(), nil, 
      'GameTooltipTemplate');

  parent:HookScript('OnEnter', function ()
    tooltip:SetOwner(parent, 'ANCHOR_NONE');
    tooltip:SetPoint('BOTTOMLEFT', parent, 'TOPLEFT', 0, 0);
    tooltip:AddLine(text);
    tooltip:Show();
  end);

  parent:HookScript('OnLeave', function () 
    tooltip:Hide();
  end);

  return tooltip;
end

function Tooltip:new (parent, text)
  local this = {};

  setmetatable(this, Tooltip);
  
  this.tooltip = createTooltip(parent, text);
end