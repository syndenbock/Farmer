local _, addon = ...;

addon.export('polyfills/C_Spell', C_Spell or {
  GetSpellInfo = function (...)
    local info = {_G.GetSpellInfo(...)};

    return {
      name = info[1],
      iconID = info[3],
      originalIconID = info[8],
      castTime = info[4],
      minRange = info[5],
      maxRange = info[6],
      spellID = info[7],

      -- Doesn't exist on retail anymore
      rank = info[2],
    };
  end,
});
