local addonName, addon = ...;

local Factory = addon.OptionFactory;

local mainPanel = Factory.Panel:New(addonName);

mainPanel:addButton('test', function ()
  print('test!');
end);

mainPanel:addCheckbox('henlo');

mainPanel:addSlider(1, 10, 'slider', '1', '2', 1);

local subPanel = Factory.Panel:New('suberino', mainPanel.panel);

subPanel:addButton('test2', function ()
  print('HELLO!');
end);