local _, addon = ...;

local xpcall = _G.xpcall;

local geterrorhandler = _G.geterrorhandler;

function addon.extend (class, key, value)
  assert(class[key] == nil, 'Key already in use: ' .. key);
  class[key] = value;
  return value;
end

local modules = {};

function addon.export (name, module)
  assert(name ~= nil);
  assert(modules[name] == nil, 'Module already exists: ' .. name);
  assert(module ~= nil, 'Cannot export nil as module: ' .. name);

  modules[name] = module;
  return module;
end

function addon.import (name)
  assert(name ~= nil);
  assert(modules[name] ~= nil, 'Module does not exist: ' .. name);

  return modules[name];
end

function addon.secureCall (callback, ...)
  xpcall(callback, geterrorhandler(), ...);
end
