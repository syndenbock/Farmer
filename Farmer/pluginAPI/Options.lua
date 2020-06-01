local _, addon = ...;

local options = {};
local Panel = addon.OptionFactory.Panel;
local mainPanel = addon.mainPanel;

addon.API.options = options;

function options:createPanel (name)
  return Panel:New(name, mainPanel);
end
