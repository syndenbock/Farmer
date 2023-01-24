local _, addon = ...;

addon.export('polyfills/C_CVar', C_CVar or {
  GetCVar = GetCVar,
  SetCVar = SetCVar,
});
