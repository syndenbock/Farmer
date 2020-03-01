local addonName, addon = ...;

local Factory = addon.OptionFactory;

local mainPanel = Factory.Panel:New(addonName);

mainPanel:addButton('test', function ()
  print('test!');
end);

mainPanel:addCheckbox('henlo');

mainPanel:addSlider(1, 10, 'slider', '1', '2', 1);

mainPanel:addLabel('This is a label');

local options = {
  {
    text = 'hallo',
    value = 'hallo',
  }, {
    text = 'was',
    value = 'was',
  }, {
    text = 'geht',
    value = 'geht',
  }, {
    text = '?',
    value = '?',
  },
};

mainPanel:addDropdown ('testdrop', options);

local subPanel = Factory.Panel:New('suberino', mainPanel.panel);

subPanel:addButton('test2', function ()
  print('HELLO!');
end);
