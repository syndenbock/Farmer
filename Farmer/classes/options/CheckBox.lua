local _, addon = ...;

local CreateFrame = _G.CreateFrame;
local CreateFromMixins = _G.CreateFromMixins;

local CheckBox =  addon.export('Class/Options/CheckBox', {});

local function createCheckBox (name, parent, text, anchors)
  local checkBox = CreateFrame('CheckButton', name .. 'CheckButton', parent, 'SettingsCheckBoxControlTemplate');

  -- TWW: CheckBox is renamed to Checkbox
  if checkBox.CheckBox then
    checkBox.Checkbox = checkBox.CheckBox
  end

  if (checkBox.Checkbox) then
    checkBox.Checkbox:ClearAllPoints();
    checkBox.Checkbox:SetPoint('LEFT', checkBox, 'LEFT', 0, 0);
    checkBox.Text:ClearAllPoints();
    checkBox.Text:SetPoint('LEFT', checkBox.Checkbox, 'RIGHT', 5, 0);
    checkBox.Text:SetText(text);
    checkBox.Text:SetJustifyH('LEFT');
  else
    -- Blizzard really knows how to write APIs. Not.
    local textFrame = _G[name .. 'CheckButtonText']

    if (textFrame ~= nil) then
      textFrame:SetText(text);
      textFrame:SetJustifyH('LEFT');
    end
  end

  checkBox:ClearAllPoints();
  checkBox:SetPoint(anchors.anchor, anchors.parent, anchors.parentAnchor,
      anchors.xOffset, anchors.yOffset);

  return checkBox;
end

function CheckBox:new (parent, name, anchorFrame, xOffset, yOffset, text,
                       anchor, parentAnchor)
  local this = CreateFromMixins(CheckBox);

  this.checkBox = createCheckBox(name, parent, text, {
    anchor = anchor or 'TOPLEFT',
    parent = anchorFrame,
    parentAnchor = parentAnchor or 'BOTTOMLEFT',
    xOffset = xOffset,
    yOffset = yOffset,
  });

  return this;
end

function CheckBox:GetValue ()
  if (self.checkBox.Checkbox) then
    return self.checkBox.Checkbox:GetChecked();
  else
    return self.checkBox:GetChecked();
  end
end

function CheckBox:SetValue (checked)
  if (self.checkBox.Checkbox) then
    return self.checkBox.Checkbox:SetChecked(checked);
  else
    return self.checkBox:SetChecked(checked);
  end
end
