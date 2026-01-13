local _, addon = ...;

local CreateFrame = _G.CreateFrame;
local CreateFromMixins = _G.CreateFromMixins;
local ToggleDropDownMenu = _G.ToggleDropDownMenu;
local UIDropDownMenu_AddButton = _G.UIDropDownMenu_AddButton;
local UIDropDownMenu_CreateInfo = _G.UIDropDownMenu_CreateInfo;
local UIDropDownMenu_JustifyText = _G.UIDropDownMenu_JustifyText;
local UIDropDownMenu_SetText = _G.UIDropDownMenu_SetText;
local UIDropDownMenu_SetWidth = _G.UIDropDownMenu_SetWidth;

local Dropdown = addon.export('client/classes/options/Dropdown', {});

local function toggleDropdown(dropdownButton)
  local parent = dropdownButton:GetParent();
  ToggleDropDownMenu(1, nil, parent, parent, 13, 11);
end

local function initDropDown(self, level)
  local currentValue = self:GetValue();

  for _, option in ipairs(self.options) do
    local info = UIDropDownMenu_CreateInfo();

    info.text = option.text;
    info.arg1 = option.value;
    info.value = option.value;
    info.checked = (currentValue == option.value);
    info.minWidth = self.width;
    info.justifyH = 'CENTER';
    info.func = function(_, arg1)
      self:SetValue(arg1);

      if option.callback then
        option.callback(arg1);
      end
    end;

    UIDropDownMenu_AddButton(info, level);
  end
end

local function createDropdown(name, parent, text, options, anchors)
  local dropdown = CreateFrame('Frame', name .. 'Dropdown', parent, 'UIDropDownMenuTemplate');
  local button = dropdown.Button;

  if (button:GetScript('OnClick')) then
    button:SetScript('OnClick', toggleDropdown);
    button:SetScript('OnMouseDown', nil);
  else
    button:SetScript('OnClick', nil);
    button:SetScript('OnMouseDown', toggleDropdown);
  end

  dropdown:SetPoint(
    anchors.anchor,
    anchors.parent,
    anchors.parentAnchor,
    anchors.xOffset - 23,
    anchors.yOffset
  );

  function dropdown:SetValue(value)
    self.value = value;
    -- The dropdown itself shall keep its text so SetText is not called
    -- UIDropDownMenu_SetText(self, value);
  end

  function dropdown:GetValue()
    return self.value;
  end

  UIDropDownMenu_SetWidth(dropdown, anchors.width);
  UIDropDownMenu_JustifyText(dropdown, 'CENTER');
  UIDropDownMenu_SetText(dropdown, text);

  dropdown.options = options;
  dropdown.width = anchors.width;

  UIDropDownMenu_Initialize(dropdown, initDropDown);

  return dropdown;
end

function Dropdown:new(parent, name, anchorFrame, xOffset, yOffset, text,
                      options, anchor, parentAnchor)
  local this = CreateFromMixins(Dropdown);

  this.dropdown = createDropdown(name, parent, text, options, {
    anchor = anchor or 'TOPLEFT',
    parent = anchorFrame,
    parentAnchor = parentAnchor or 'BOTTOMLEFT',
    xOffset = xOffset,
    yOffset = yOffset,
    width = 145,
  });

  return this;
end

function Dropdown:SetValue(value)
  self.dropdown:SetValue(value);
end

function Dropdown:GetValue()
  return self.dropdown:GetValue();
end
