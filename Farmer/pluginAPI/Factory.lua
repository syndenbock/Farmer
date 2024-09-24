local _, addon = ...;

local SavedVariables = addon.import('client/utils/SavedVariables');

addon.export('API/Factory',  {
  SavedVariablesHandler = SavedVariables.SavedVariablesHandler,
});
