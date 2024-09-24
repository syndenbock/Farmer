local _, addon = ...;

local module = addon.export('main/Main', {});

module.frame = addon.import('core/widgets/DataMessageModeFrame'):New({
  name = 'farmerFrame',
});
