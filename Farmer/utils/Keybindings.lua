local addonName, addon = ...;

function addon.exposeHeader (headerName, text)
  local bindingToken = 'BINDING_HEADER_FARMER_' .. headerName;

  assert(_G[bindingToken] == nil,
    addonName .. ': binding already exists: "' .. headerName .. '"');

  _G[bindingToken] = text;
end

function addon.exposeBinding(bindingName, text, handler)
  local bindingToken = 'BINDING_NAME_FARMER_' .. bindingName;
  local handlerToken = 'FARMER_' .. bindingName;

  assert(_G[bindingToken] == nil,
      addonName .. ': binding already exists: "' .. bindingName .. '"');
  assert(_G[handlerToken] == nil,
      addonName .. ': handler already exists: "' .. bindingName .. '"');

  _G[bindingToken] = text;
  _G[handlerToken] = handler;
end
