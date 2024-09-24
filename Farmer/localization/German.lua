local _, addon = ...

if (_G.GetLocale() ~= 'deDE') then return end

local L = addon.L;

L["unknown command"] = "Unbekannter Befehl"
L[ [=[You seem to have used an old Version of Farmer
Check out all the new features in the options!]=] ] = "Du scheinst zuvor eine alte Version von Farmer verwendet zu haben. Sieh dir alle neuen Features in den Optionen an!"

-- Currencies
L["Currencies"] = "Währungen"
L["ignore Honor"] = "Ignoriere Ehre"
L["show currencies"] = "Zeige Währungen"

-- Display
L["always show names"] = "Zeige Namen immer an"
L["center"] = "mittig"
L["display time"] = "Anzeigedauer"
L["don't display at mailboxes"] = "Keine Anzeige an Briefkästen"
L["don't display in arena"] = "Keine Anzeige in der Arena"
L["down"] = "Nach unten"
L["font size"] = "Textgröße"
L["grow direction"] = "Wachstumsrichtung"
L["left"] = "links"
L["line spacing"] = "Zeilenabstand"
L["Monochrome"] = "Monochrom"
L["move display"] = "Verschiebe Anzeige"
L["None"] = "Keine"
L["outline mode"] = "Textumrandung"
L["reset position"] = "Position zurücksetzen"
L["right"] = "rechts"
L["text alignment"] = "Textausrichtung"
L["Thick"] = "Breit"
L["Thick Monochrome"] = "Breit Monochrom"
L["Thin"] = "Dünn"
L["up"] = "Nach oben"

-- Experience
L["Experience"] = "Erfahrung"
L["minimum %"] = "Minimale %"
L["show experience"] = "Zeige Erfahrungspunkte"

-- Farm radar
L["enable tooltips for default nodes"] = "Erlaube tooltips für spielinterne Icons"
L["Farm radar"] = "Farmradar"
L["It's recommended to enable shrinking the minimap when enabling this"] = "Es wird empfohlen, beim Verwenden dieser Option das Schrumpfen der Minimap zu aktivieren"
L["show addon node tooltips"] = "Erlaube tooltips von Icons, die von Addons stammen "
L["shrink minimap to radar size"] = "Schrumpfe Minimap auf die Größe des Radars"
L["This will block all mouseovers under the minimap in farm mode!"] = "Diese Option blockiert sämtliche Mouseover-Aktionen unter der Minimap, solange der Farmmodus aktiv ist!"
L["Toggle farming radar"] = "Farmradar an/ausschalten"

-- Items
L["always show focused items"] = "Zeige Items im Fokus immer an"
L["always show quest items"] = "Zeige Questitems immer an"
L["always show reagents"] = "Zeige Reagenzien immer an"
L["always show recipes"] = "Zeige Rezepte immer an"
L["focused item ids:"] = "Ids fokussierter Items:"
L["icon scale"] = "Iconskalierung"
L["Items"] = "Items"
L["minimum"] = "Minimum"
L["minimum rarity"] = "Mindestseltenheit"
L["only show focused items"] = "Zeige nur Items im Fokus an"
L["show bag count for items"] = "Zeige Anzahl von Items in der Tasche"
L["show item levels for equipment"] = "Zeige Itemlevel von Ausrüstung"
L["show items based on rarity"] = "Zeige Items nach Seltenheit an"
L["show total count for items"] = "Zeige Gesamtanzahl von Items"

-- Minimap
L["display vignettes that appear on the minimap"] = "Zeige Vignetten, die auf der Minimap erscheinen"
L["Minimap"] = "Minimap"

-- Misc
L["enable fast autoloot"] = "Aktiviere schnelles Autolooten"
L["hide health bars while fishing"] = "Verstecke Lebensbalken beim Angeln"
L["hide loot and item roll toasts"] = "Verstecke Loot- und Würfel-Popups"
L["Misc"] = "Extra"

-- Money
L["Money"] = "Gold"
L["Money counter was reset"] = "Geldzähler wurde zurückgesetzt"
L["Money earned this session: "] = "Während dieser Session verdientes Geld: "
L["Money lost this session: "] = "Während dieser Session verlorenes Geld: "
L["show money"] = "Zeige Geld"

-- Professions
L["Professions"] = "Berufe"
L["show profession levelups"] = "Zeige Berufsaufstiege"

-- Reputation
L["Reputation"] = "Ruf"
L["show reputation"] = "Zeige Ruf"

-- Sell and Repair
L["allow using guild funds for autorepair"] = "Erlaube das automatische Reparieren mit Gold der Gilde"
L["autorepair when visiting merchants"] = "Repariere automatisch beim Besuchen eines Händlers"
L["autosell gray items when visiting merchants"] = "Verkaufe automatisch graue items beim Besuchen eines Händlers"
L["Equipment has been repaired by your guild for %s"] = "Ausrüstung wurde von deiner Gilde für %s repariert"
L["Equipment has been repaired for %s"] = "Ausrüstung wurde für %s repariert"
L["Not enough gold for repairing your gear"] = "Nicht genug Gold zum Reparieren der Ausrüstung"
L["Sell and Repair"] = "Verkaufen und Reparieren"
L["Selling gray items for %s"] = "Verkaufe graue items für %s"
L["skip readable items when autoselling"] = "Überspringe lesbare items beim automatischen Verkaufen"

-- Skills
L["show skill levelups"] = "Zeige Fertigkeitsaufstiege"
L["Skills"] = "Fertigkeiten"
