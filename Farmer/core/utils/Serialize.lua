local _, addon = ...;

local strsplit = _G.strsplit;
local strjoin = _G.strjoin;
local strsub = _G.strsub;
local strfind = _G.strfind;
local strlen = _G.strlen;
local unpack = _G.unpack;

function addon.serialize (...)
  local data = {...};
  local info = {};
  local dataString = '';

  for _, fragment in ipairs(data) do
    fragment = tostring(fragment);
    table.insert(info, strlen(fragment));
    dataString = dataString .. fragment;
  end

  info = strjoin(',', unpack(info)) .. ';';

  return info .. dataString;
end

function addon.deserialize (dataString)
  local position = strfind(dataString, ';');
  local info = strsub(dataString, 1, position - 1);
  local data = {};

  dataString = strsub(dataString, position + 1);
  info = {strsplit(',', info)};

  for _, fragment in ipairs(info) do
    local length = tonumber(fragment);

    table.insert(data, strsub(dataString, 1, length));
    dataString = strsub(dataString, length + 1);
  end

  return data;
end
