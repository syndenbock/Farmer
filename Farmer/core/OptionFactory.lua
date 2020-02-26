local addonName, addon = ...;

local Factory = {};

addon.OptionFactory = Factory;

do
  local Panel = {};
  local panelCount = 0;

  Panel.__index = Panel;

  local function getPanelName ()
    local panelName = addonName .. 'Panel' .. panelCount;

    panelCount = panelCount + 1;

    return panelName;
  end

  function Panel:New (name, parent)
    parent = parent or UIParent;

    local this = {};
    local panel = CreateFrame('Frame', getPanelName(), parent);

    setmetatable(this, Panel);

    this.parent = parent;
    this.name = name;
    this.panel = panel;
    this.anchor = {
      x = 10,
      y = 10,
    };


    panel.name = name;
    panel.parent = parent.name;

    InterfaceOptions_AddCategory(panel);

    this.anchor = {
      x = 10,
      y = -10,
    };

    this.childCount = 0;

    return this;
  end

  function Panel:addButton (text, onClick)
    local name = self.name .. 'child' .. self.childCount;
    local button = Factory.Button:New(self.panel, name, self.panel, self.anchor.x, self.anchor.y, text, 'TOPLEFT', 'TOPLEFT', onClick);

    self.childCount = self.childCount + 1;
    self.anchor.y = self.anchor.y - 7 - button.button:GetHeight();

    return button;
  end

  function Panel:addCheckbox (text)
    local name = self.name .. 'child' .. self.childCount;
    local checkBox = Factory.CheckBox:New(self.panel, name, self.panel, self.anchor.x, self.anchor.y, text, 'TOPLEFT', 'TOPLEFT', onClick);

    self.childCount = self.childCount + 1;
    self.anchor.y = self.anchor.y - 7 - checkBox.checkBox:GetHeight();

    return checkBox;
  end

  Factory.Panel = Panel;
end

do
  local Button = {};

  Button.__index = Button;

  function Button:New (parent, name, anchorFrame, xOffset, yOffset, text, anchor, parentAnchor, onClick)
    local this = {};
    local button = CreateFrame('Button', name .. 'Button', parent, 'OptionsButtonTemplate');

    setmetatable(this, Button);

    this.button = button;

    anchor = anchor or 'TOPLEFT';
    parentAnchor = parentAnchor or 'BOTTOMLEFT';

    button:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset);
    button:SetSize(150, 25);
    button:SetText(text);

    if (onClick ~= nil) then
      this:onClick(onClick);
    end

    return this;
  end

  function Button:onClick (callback)
    self.button:SetScript('OnClick', callback);
  end

  Factory.Button = Button;
end

do
  local CheckBox = {};

  CheckBox.__index = CheckBox;

  function CheckBox:New (parent, name, anchorFrame, xOffset, yOffset, text, anchor, parentAnchor)
    local this = {};
    local checkBox = CreateFrame('CheckButton', name .. 'CheckButton', parent, 'OptionsCheckButtonTemplate')

    setmetatable(this, CheckBox);

    this.checkBox = checkBox;

    anchor = anchor or 'TOPLEFT';
    parentAnchor = parentAnchor or 'BOTTOMLEFT';

    checkBox:SetPoint(anchor, anchorFrame, parentAnchor, xOffset, yOffset);

    -- Blizzard really knows how to write APIs. Not.
    _G[name .. 'CheckButtonText']:SetText(text);
    _G[name .. 'CheckButtonText']:SetJustifyH('LEFT');

    print(checkBox.Text);
    print(checkBox.text);

    -- Blizzard broke something in the BfA beta, so we have to fix it
    checkBox.SetValue = function (table, value)
      addon:printTable(table);
      print(value);
    end

    return this;
  end

  function CheckBox:GetValue ()
    return self.checkBox:GetChecked();
  end

  Factory.CheckBox = CheckBox;
end