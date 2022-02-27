local _, addon = ...;

local options = addon.export('API/options', {});
local Panel = addon.Class.Options.Panel;
local mainPanel = addon.mainPanel;

function options.createPanel (name)
  return Panel:new(name, mainPanel);
end
