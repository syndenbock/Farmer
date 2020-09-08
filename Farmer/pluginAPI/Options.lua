local _, addon = ...;

local options = {};
local Panel = addon.OptionClass.Panel;
local mainPanel = addon.mainPanel;

addon.API.options = options;

function options.createPanel (name)
  return Panel:new(name, mainPanel);
end
