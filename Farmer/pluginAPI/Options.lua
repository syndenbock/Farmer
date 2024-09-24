local _, addon = ...;

local Panel = addon.import('client/classes/options/Panel');
local Options = addon.import('main/Options');

local module = addon.export('API/options', {});

function module.createPanel (name)
  return Panel:new(name, Options.mainPanel);
end
