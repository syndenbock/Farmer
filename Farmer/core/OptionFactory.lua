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

    this.panel = panel;
    this.name = name;
    this.anchor = {
      x = 10,
      y = 10,
    };

    this.parent = parent;

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

    return button;
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
    button:SetWidth(150);
    button:SetHeight(25);
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