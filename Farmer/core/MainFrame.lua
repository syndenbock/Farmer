local _, addon = ...;

addon.frame = addon.Widget.MessageFrame:New({
  name = 'farmerFrame',
  frameStrata = 'TOOLTIP',
  frameLevel = 2,
  fading = true,
  fadeDuration = 1,
});
