local _, addon = ...;

local factory = {};

addon.API.Factory = factory;
addon.API.factory = factory;

factory.SavedVariablesHandler = addon.SavedVariablesHandler;
factory.CallbackHandler = addon.Factory.CallbackHandler;
