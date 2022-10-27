local _, addon = ...;

local CreateFrame = _G.CreateFrame;
local CreateFromMixins = _G.CreateFromMixins;

local CheckBox =  addon.export('Class/Options/CheckBox', {});

local function createCheckBox (name, parent, text, anchors)
  local checkBox = CreateFrame('CheckButton', name .. 'CheckButton', parent,
      _G.SettingsCheckBoxControlMixin and 'SettingsCheckBoxControlTemplate' or 'OptionsCheckButtonTemplate');

  if (checkBox.CheckBox) then
    checkBox.CheckBox:ClearAllPoints();
    checkBox.CheckBox:SetPoint('LEFT', checkBox, 'LEFT', 0, 0);
    checkBox.Text:ClearAllPoints();
    checkBox.Text:SetPoint('LEFT', checkBox.CheckBox, 'RIGHT', 5, 0);
    checkBox.Text:SetText(text);
    checkBox.Text:SetJustifyH('LEFT');
  else
    -- Blizzard really knows how to write APIs. Not.
    _G[name .. 'CheckButtonText']:SetText(text);
    _G[name .. 'CheckButtonText']:SetJustifyH('LEFT');
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
  if (self.checkBox.CheckBox) then
    return self.checkBox.CheckBox:GetChecked();
  else
    return self.checkBox:GetChecked();
  end
end

function CheckBox:SetValue (checked)
  if (self.checkBox.CheckBox) then
    return self.checkBox.CheckBox:SetChecked(checked);
  else
    return self.checkBox:SetChecked(checked);
  end
end
