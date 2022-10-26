local addonName, addon = ...;

local CreateFrame = _G.CreateFrame;
local CreateFromMixins = _G.CreateFromMixins;

local Settings = _G.Settings;
local InterfaceOptionsFrame_OpenToCategory = _G.InterfaceOptionsFrame_OpenToCategory;
local InterfaceOptionsFrame_Show = _G.InterfaceOptionsFrame_Show;
local InterfaceOptions_AddCategory = _G.InterfaceOptions_AddCategory;

local UIParent = _G.UIParent;

local OptionClasses = addon.Class.Options;
local Button = OptionClasses.Button;
local CheckBox = OptionClasses.CheckBox;
local Slider = OptionClasses.Slider;
local Label = OptionClasses.Label;
local Dropdown = OptionClasses.Dropdown;
local EditBox = OptionClasses.EditBox;
local CallbackHandler = addon.Class.CallbackHandler;

local Panel = addon.export('Class/Options/Panel', {});
local panelCount = 0;
local lastOpenedPanel;

local function generatePanelName ()
  local panelName = addonName .. 'Panel' .. panelCount;

  panelCount = panelCount + 1;

  return panelName;
end

function Panel:new (name, parent)
  parent = parent or UIParent;

  local this = CreateFromMixins(Panel);
  local panel = CreateFrame('Frame', generatePanelName(), parent);

  this.name = name;
  this.panel = panel;
  this.anchor = {
    x = 10,
    y = 10,
  };
  this.callbackHandler = CallbackHandler:new();
  panel.name = name;
  panel.parent = parent.name;

  this:addPanelHandler('OnCommit', 'okay');
  this:addPanelHandler('OnDefault', 'default');
  this:addPanelHandler('OnRefresh', 'refresh');
  this:addPanelHandler('OnCanel', 'cancel');

  if (Settings) then
    local category = Settings.GetCategory(parent.name);

    if (category) then
      category = Settings.RegisterCanvasLayoutSubcategory(category, panel, name);
      category.ID = name;
    else
      category = Settings.RegisterCanvasLayoutCategory(panel, name);
      category.ID = name;
      Settings.RegisterAddOnCategory(category);
    end
  else
    InterfaceOptions_AddCategory(panel, addonName);
  end

  this.anchor = {
    x = 10,
    y = -10,
  };

  this.childCount = 0;

  panel:HookScript('OnShow', function ()
    lastOpenedPanel = this;
  end);

  return this;
end

function Panel.openLastPanel ()
  if (lastOpenedPanel) then
    lastOpenedPanel:open();

    return true;
  end

  return false;
end

function Panel:__createChildName ()
  local name = self.name .. 'child' .. self.childCount;

  self.childCount = self.childCount + 1;

  return name;
end

function Panel:__getCallbackHandler ()
  return self.callbackHandler;
end

function Panel:__addCallback (identifier, callback)
  local callbackHandler = self:__getCallbackHandler();

  callbackHandler:addCallback(identifier, callback);
  self:addPanelHandler(identifier);
end

function Panel:addPanelHandler (identifier, ...)
  local function handler ()
    self:__getCallbackHandler():call(identifier);
  end

  self.panel[identifier] = handler;
  for x = 1, select('#', ...), 1 do
    self.panel[select(x, ...)] = handler;
  end
end

function Panel:open ()
  if (Settings) then
    Settings.OpenToCategory(self.panel.name);
  else
    InterfaceOptionsFrame_Show();
    InterfaceOptionsFrame_OpenToCategory(self.panel.name);
  end
end

function Panel:OnSave (callback)
  self:__addCallback('OnCommit', callback);
end

function Panel:OnCancel (callback)
  self:__addCallback('OnCancel', callback);
end

function Panel:OnLoad (callback)
  self:__addCallback('OnRefresh', callback);
end

function Panel:mapOptions (options, optionMap)
  self:OnSave(function ()
    for option, element in pairs(optionMap) do
      options[option] = element:GetValue();
    end
  end);

  self:OnLoad(function ()
    for option, element in pairs(optionMap) do
      element:SetValue(options[option]);
    end
  end);
end

function Panel:addButton (text, onClick)
  local button = Button:new(self.panel, self:__createChildName(), self.panel,
      self.anchor.x + 3, self.anchor.y, text, 'TOPLEFT', 'TOPLEFT', onClick);

  self.anchor.y = self.anchor.y - 7 - button.button:GetHeight();

  return button;
end

function Panel:addCheckBox (text, onClick)
  local checkBox = CheckBox:new(self.panel, self:__createChildName(),
      self.panel, self.anchor.x, self.anchor.y, text, 'TOPLEFT', 'TOPLEFT',
      onClick);

  self.anchor.y = self.anchor.y - 7 - checkBox.checkBox:GetHeight();

  return checkBox;
end

function Panel:addSlider (min, max, text, lowText, highText, precision)
  local slider = Slider:new(self.panel, self:__createChildName(),
      self.panel, self.anchor.x + 12, self.anchor.y - 15, text, min, max,
      lowText, highText, 'TOPLEFT', 'TOPLEFT', precision);

  self.anchor.y = self.anchor.y - 25 - slider:GetHeight();

  return slider;
end

function Panel:addLabel (text)
  local label = Label:new(self.panel, self.panel, self.anchor.x + 3,
      self.anchor.y, text, 'TOPLEFT', 'TOPLEFT')

  self.anchor.y = self.anchor.y - 7 - label.label:GetHeight();

  return label;
end

function Panel:addDropdown (text, options)
  local dropdown = Dropdown:new(self.panel, self:__createChildName(),
      self.panel, self.anchor.x + 10, self.anchor.y, text, options, 'TOPLEFT',
      'TOPLEFT');

  self.anchor.y = self.anchor.y - 3 - dropdown.dropdown:GetHeight();

  return dropdown;
end

function Panel:addEditBox (width, height)
  local editBox = EditBox:new(self.panel, self:__createChildName(),
      self.panel, self.anchor.x + 2, self.anchor.y, width, height, 'TOPLEFT',
      'TOPLEFT');

  self.anchor.y = self.anchor.y - 7 - height;

  return editBox;
end
