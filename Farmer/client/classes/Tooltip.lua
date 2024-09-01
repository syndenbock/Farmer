local _, addon = ...;

local CreateFromMixins = _G.CreateFromMixins;
local GameTooltip = _G.GameTooltip;

local Tooltip = addon.export('Factory/Tooltip', {});

local function displayLines (lines)
  GameTooltip:ClearLines();

  for _, line in ipairs(lines) do
    GameTooltip:AddLine(line);
  end
end

local function hideGameTooltip ()
  GameTooltip:Hide();
end

local function createTooltip (self, parent)
  parent:HookScript('OnEnter', function ()
    GameTooltip:SetOwner(parent, 'ANCHOR_NONE');
    GameTooltip:ClearAllPoints();
    GameTooltip:SetPoint('BOTTOMLEFT', parent, 'TOPLEFT', 0, 0);
    displayLines(self.text);
    GameTooltip:Show();
  end);

  parent:HookScript('OnLeave', hideGameTooltip);
end

function Tooltip:new (parent, text)
  local this = CreateFromMixins(Tooltip);

  this:setText(text);
  createTooltip(this, parent);

  return this;
end

function Tooltip:setText (text)
  if (type(text) ~= 'table') then
    text = {text};
  end

  self.text = text;
end
