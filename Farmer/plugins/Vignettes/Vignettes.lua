local _, addon = ...;

local truncate = addon.truncate;

addon.listen('NEW_VIGNETTE', function (info, coords)
  print(info.name, truncate(coords.x, 1), truncate(coords.y, 1));
end);
