local _, addon = ...;

local Serialize = addon.import('core/utils/Serialize');

addon.export('API/serialize', Serialize.serialize);
addon.export('API/deserialize', Serialize.deserialize);
