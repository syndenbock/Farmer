local _, addon = ...;

local C_CVar = _G.C_CVar or {};

addon.export('polyfills/C_CVar', {
  GetCVar = C_CVar.GetCVar or _G.GetCVar,
  SetCVar = C_CVar.SetCVar or _G.SetCVar,
});
