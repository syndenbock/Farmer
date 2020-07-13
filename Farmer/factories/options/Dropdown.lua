local _, addon = ...;

local CreateFrame = _G.CreateFrame;
local UIDropDownMenu_SetWidth = _G.UIDropDownMenu_SetWidth;
local UIDropDownMenu_SetText = _G.UIDropDownMenu_SetText;
local UIDropDownMenu_Initialize = _G.UIDropDownMenu_Initialize;
local UIDropDownMenu_CreateInfo = _G.UIDropDownMenu_CreateInfo;
local UIDropDownMenu_AddButton = _G.UIDropDownMenu_AddButton;

local Factory = addon:share('OptionFactory');

local Dropdown = {};

Factory.Dropdown = Dropdown;

Dropdown.__index = Dropdown;

function Dropdown:New (parent, name, anchorFrame, xOffset, yOffset, text,
                       options, anchor, parentAnchor)
  local this = {};
  local dropdown = CreateFrame('Frame', name .. 'Dropdown', parent,
      'UIDropDownMenuTemplate');

  setmetatable(this, Dropdown);

  this.dropdown = dropdown;
  this.currentValue = options[1].value;

  anchor = anchor or 'TOPLEFT';
  parentAnchor = parentAnchor or 'BOTTOMLEFT';

  dropdown:SetPoint(anchor, anchorFrame, parentAnchor, xOffset - 23, yOffset);

  UIDropDownMenu_SetWidth(dropdown, 138);
  UIDropDownMenu_SetText(dropdown, text);

  UIDropDownMenu_Initialize(dropdown,
      this:GenerateInitializer(dropdown, options));

  function dropdown:SetValue (value)
    this:SetValue(value);
  end

  return this;
end

function Dropdown:GenerateInitializer (dropdown, options)
  local this = self;

  local function initializer (_, level)
    local info = UIDropDownMenu_CreateInfo();

    for i = 1, #options do
      local option = options[i];

      info.func = dropdown.SetValue;
      info.text = option.text;
      info.arg1 = option.value;
      info.checked = (this.currentValue == option.value);
      UIDropDownMenu_AddButton(info, level);
    end
  end

  return initializer;
end

function Dropdown:SetValue (value)
  self.currentValue = value;
end

function Dropdown:GetValue ()
  return self.currentValue;
end
