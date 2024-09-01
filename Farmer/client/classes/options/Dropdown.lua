local _, addon = ...;

local CreateFrame = _G.CreateFrame;
local CreateFromMixins = _G.CreateFromMixins;
local ToggleDropDownMenu = _G.ToggleDropDownMenu;
local UIDropDownMenu_AddButton = _G.UIDropDownMenu_AddButton;
local UIDropDownMenu_CreateInfo = _G.UIDropDownMenu_CreateInfo;
local UIDropDownMenu_Initialize = _G.UIDropDownMenu_Initialize;
local UIDropDownMenu_JustifyText = _G.UIDropDownMenu_JustifyText;
local UIDropDownMenu_SetText = _G.UIDropDownMenu_SetText;
local UIDropDownMenu_SetWidth = _G.UIDropDownMenu_SetWidth;

local Dropdown = addon.export('Class/Options/Dropdown', {});

local function generateDropdownInitializer (dropdown, options, width)
  local function initializer (_, level)
    local info = UIDropDownMenu_CreateInfo();
    local currentValue = dropdown:GetValue();

    info.minWidth = width;
    info.justifyH = 'CENTER';

    for _, option in ipairs(options) do
      info.func = dropdown.SetValue;
      info.text = option.text;
      info.arg1 = option.value;
      info.value = option.value;
      info.checked = (currentValue == option.value);
      UIDropDownMenu_AddButton(info, level);
    end
  end

  return initializer;
end

local function toggleDropdown (dropdownButton)
  local parent = dropdownButton:GetParent();

  ToggleDropDownMenu(1, nil, parent, parent, 13, 11);
end

local function createDropdown (name, parent, text, options, anchors)
  local dropdown = CreateFrame('Frame', name .. 'Dropdown', parent,
      'UIDropDownMenuTemplate');
  local button = dropdown.Button;
  local currentValue;

  --[[ Classic uses "OnClick" for  dropdowns, while retail uses "OnMouseDown",
    so we detect which one is the case and set the other handler to nil for
    reliability ]]
  if (button:GetScript('OnClick')) then
    button:SetScript('OnClick', toggleDropdown);
    button:SetScript('OnMouseDown', nil);
  else
    button:SetScript('OnClick', nil);
    button:SetScript('OnMouseDown', toggleDropdown);
  end

  dropdown:SetPoint(anchors.anchor, anchors.parent, anchors.parentAnchor,
      anchors.xOffset - 23, anchors.yOffset);

  function dropdown:SetValue (value)
    currentValue = value;
  end

  function dropdown:GetValue ()
    return currentValue;
  end

  UIDropDownMenu_SetWidth(dropdown, anchors.width);
  UIDropDownMenu_JustifyText(dropdown, 'CENTER');
  UIDropDownMenu_SetText(dropdown, text);

  UIDropDownMenu_Initialize(dropdown,
      generateDropdownInitializer(dropdown, options, anchors.width));

  return dropdown;
end

function Dropdown:new (parent, name, anchorFrame, xOffset, yOffset, text,
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

function Dropdown:SetValue (value)
  self.dropdown:SetValue(value);
end

function Dropdown:GetValue ()
  return self.dropdown:GetValue();
end
