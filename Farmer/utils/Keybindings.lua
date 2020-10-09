local addonName, addon = ...;

function addon.exposeHeader (headerName, text)
  local bindingToken = "BINDING_HEADER_FARMER_" .. headerName;

  assert(_G[bindingToken] == nil,
    addonName .. ': binding already exists: "' .. headerName .. '"');

  _G[bindingToken] = text;
end

function addon.exposeBinding(bindingName, text, handler)
  local bindingToken = "BINDING_NAME_FARMER_" .. bindingName;

  assert(_G[bindingToken] == nil,
    addonName .. ': binding already exists: "' .. bindingName .. '"');

  _G[bindingToken] = text;
  _G[bindingToken .. '_HANDLER'] = handler;
end

addon.exposeHeader('HEADER', addonName);
