local _, addon = ...;

local module = addon.export('pluginAPI/API', {
  import = addon.import,
});

_G.FARMER_API = module;
