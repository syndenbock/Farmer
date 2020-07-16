local _, addon = ...;

local CreateFrame = _G.CreateFrame;
local UIDropDownMenu_SetWidth = _G.UIDropDownMenu_SetWidth;
local UIDropDownMenu_SetText = _G.UIDropDownMenu_SetText;
local UIDropDownMenu_Initialize = _G.UIDropDownMenu_Initialize;
local UIDropDownMenu_CreateInfo = _G.UIDropDownMenu_CreateInfo;
local UIDropDownMenu_AddButton = _G.UIDropDownMenu_AddButton;

local Factory = addon.share('OptionFactory');

local Dropdown = {};

Factory.Dropdown = Dropdown;

Dropdown.__index = Dropdown;

local function generateDropdownInitializer (dropdown, options)
  local function initializer (_, level)
    local info = UIDropDownMenu_CreateInfo();

    for i = 1, #options do
      local option = options[i];

      info.func = dropdown.SetValue;
      info.text = option.text;
      info.arg1 = option.value;
      info.checked = (dropdown.value == option.value);
      UIDropDownMenu_AddButton(info, level);
    end
  end

  return initializer;
end

local function createDropdown (name, parent, text, options, anchors)
  local dropdown = CreateFrame('Frame', name .. 'Dropdown', parent,
      'UIDropDownMenuTemplate');

  dropdown:SetPoint(anchors.anchor, anchors.parent, anchors.parentAnchor,
      anchors.xOffset - 23, anchors.yOffset);

  function dropdown:SetValue (value)
    dropdown.value = value;
  end

  function dropdown:GetValue ()
    return dropdown.value;
  end

  UIDropDownMenu_SetWidth(dropdown, 138);
  UIDropDownMenu_SetText(dropdown, text);

  UIDropDownMenu_Initialize(dropdown,
      generateDropdownInitializer(dropdown, options));

  return dropdown;
end

function Dropdown:new (parent, name, anchorFrame, xOffset, yOffset, text,
                       options, anchor, parentAnchor)
  local this = {};

  setmetatable(this, Dropdown);

  this.dropdown = createDropdown(name, parent, text, options, {
    anchor = anchor or 'TOPLEFT',
    parent = anchorFrame,
    parentAnchor = parentAnchor or 'BOTTOMLEFT',
    xOffset = xOffset,
    yOffset = yOffset,
  });

  return this;
end

function Dropdown:SetValue (value)
  self.dropdown:SetValue(value);
end

function Dropdown:GetValue ()
  return self.dropdown:GetValue();
end
