local addonName, addon = ...;

local CreateFrame = _G.CreateFrame;
local CreateFromMixins = _G.CreateFromMixins;
local geterrorhandler = _G.geterrorhandler;
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

local Panel = {};
local panelCount = 0;
local lastOpenedPanel;

OptionClasses.Panel = Panel;

local function generatePanelName ()
  local panelName = addonName .. 'Panel' .. panelCount;

  panelCount = panelCount + 1;

  return panelName;
end

function Panel:new (name, parent)
  parent = parent or UIParent;

  local this = CreateFromMixins(Panel);
  local panel = CreateFrame('Frame', generatePanelName(), parent);

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
  if (self.callbackHandler == nil) then
    self.callbackHandler = CallbackHandler:new();
  end

  return self.callbackHandler;
end

function Panel:__addCallback (identifier, callback)
  local callbackHandler = self:__getCallbackHandler();
  -- it's necessary to use a safe call with pcall to detect errors as the
  -- options panel catches errors in option panel handlers

  local safeCall = function ()
    local success, errorMessage = pcall(callback);

    if (not success) then
      geterrorhandler()(addonName .. ': error in ' .. identifier .. ' handler: ' .. errorMessage);
    end
  end

  if (callbackHandler:addCallback(identifier, safeCall)) then
    self.panel[identifier] = function ()
      callbackHandler:call(identifier);
    end
  end
end

function Panel:open ()
  InterfaceOptionsFrame_Show();
  InterfaceOptionsFrame_OpenToCategory(self.panel);
end

function Panel:OnSave (callback)
  self:__addCallback('okay', callback);
end

function Panel:OnCancel (callback)
  self:__addCallback('cancel', callback);
end

function Panel:OnLoad (callback)
  self:__addCallback('refresh', callback);
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
