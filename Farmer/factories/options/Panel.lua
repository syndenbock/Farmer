local addonName, addon = ...;

local CreateFrame = _G.CreateFrame;
local InterfaceOptions_AddCategory = _G.InterfaceOptions_AddCategory;
local UIParent = _G.UIParent;

local Factory = addon.share('OptionFactory');

local Panel = {};
local panelCount = 0;

Factory.Panel = Panel;

Panel.__index = Panel;

local function generatePanelName ()
  local panelName = addonName .. 'Panel' .. panelCount;

  panelCount = panelCount + 1;

  return panelName;
end

function Panel:new (name, parent)
  parent = parent or UIParent;

  local this = {};
  local panel = CreateFrame('Frame', generatePanelName(), parent);

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

function Panel:getChildName ()
  local name = self.name .. 'child' .. self.childCount;

  self.childCount = self.childCount + 1;

  return name;
end

function Panel:OnSave (callback)
  self.panel.okay = callback;
end

function Panel:OnCancel (callback)
  self.panel.cancel = callback;
end

function Panel:OnLoad (callback)
  self.panel.refresh = callback;
end

function Panel:addButton (text, onClick)
  local button = Factory.Button:new(self.panel, self:getChildName(), self.panel,
      self.anchor.x + 3, self.anchor.y, text, 'TOPLEFT', 'TOPLEFT', onClick);

  self.anchor.y = self.anchor.y - 7 - button.button:GetHeight();

  return button;
end

function Panel:addCheckBox (text, onClick)
  local checkBox = Factory.CheckBox:new(self.panel, self:getChildName(),
      self.panel, self.anchor.x, self.anchor.y, text, 'TOPLEFT', 'TOPLEFT',
      onClick);

  self.anchor.y = self.anchor.y - 7 - checkBox.checkBox:GetHeight();

  return checkBox;
end

function Panel:addSlider (min, max, text, lowText, highText, stepSize)
  local slider = Factory.Slider:new(self.panel, self:getChildName(), self.panel,
      self.anchor.x + 12, self.anchor.y - 15, text, min, max, lowText, highText,
      'TOPLEFT', 'TOPLEFT', stepSize);

  self.anchor.y = self.anchor.y - 25 - slider:GetHeight();

  return slider;
end

function Panel:addLabel (text)
  local label = Factory.Label:new(self.panel, self.panel, self.anchor.x + 3,
      self.anchor.y, text, 'TOPLEFT', 'TOPLEFT')

  self.anchor.y = self.anchor.y - 7 - label.label:GetHeight();

  return label;
end

function Panel:addDropdown (text, options)
  local dropdown = Factory.Dropdown:new(self.panel, self:getChildName(),
      self.panel, self.anchor.x + 10, self.anchor.y, text, options, 'TOPLEFT',
      'TOPLEFT');

  self.anchor.y = self.anchor.y - 7 - dropdown.dropdown:GetHeight();

  return dropdown;
end

function Panel:addEditBox (width, height)
  local editBox = Factory.EditBox:new(self.panel, self:getChildName(),
      self.panel, self.anchor.x + 2, self.anchor.y, width, height, 'TOPLEFT',
      'TOPLEFT');

  self.anchor.y = self.anchor.y - 7 - height;

  return editBox;
end
