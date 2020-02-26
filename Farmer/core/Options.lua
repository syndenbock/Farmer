local addonName, addon = ...;

local Factory = addon.OptionFactory;

local mainPanel = Factory.Panel:New(addonName);

mainPanel:addButton('test', function ()
  print('test!');
end);

mainPanel:addCheckbox('henlo');

local subPanel = Factory.Panel:New('suberino', mainPanel.panel);

subPanel:addButton('test2', function ()
  print('HELLO!');
end);