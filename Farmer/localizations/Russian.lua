local _, addon = ...

if (_G.GetLocale() ~= 'ruRU') then return end

local L = addon.L;

L["unknown command"] = "Неизвестная команда"
L[ [=[You seem to have used an old Version of Farmer
Check out all the new features in the options!]=] ] = [=[Похоже, вы использовали старую версию Farmer
Проверьте все новые функции в опциях!]=]

-- Currencies
L["Currencies"] = "Валюты"
L["ignore Honor"] = "Игнорировать честь"
L["show currencies"] = "Показывать валюту"

-- Display
L["center"] = "по центру"
L["display time"] = "Время отображения"
L["don't display at mailboxes"] = "Не показывать добычу из почтовых ящиков"
L["don't display in arena"] = "Не показывать на арене"
L["don't display on island expeditions"] = "Не показывать на островных экспедициях"
L["down"] = "вниз"
L["font size"] = "Размер шрифта"
L["grow direction"] = "Направление роста текста добычи"
L["left"] = "слева"
L["line spacing"] = "Межстрочный интервал"
L["Monochrome"] = "Одноцветный"
L["move display"] = "Переместить текст"
L["None"] = "Ничего"
L["outline mode"] = "Режим контура текста"
L["reset position"] = "Сбросить расположение"
L["right"] = "справа"
L["always show names"] = "Показывать названия всех предметов"
L["text alignment"] = "Выравнивание текста"
L["Thick"] = "Жирный"
L["Thick Monochrome"] = "Жирный одноцветный"
L["Thin"] = "Тонкий"
L["up"] = "вверх"

-- Farm radar
L["enable tooltips for default nodes"] = "включить всплывающие подсказки для добычи по умолчанию"
L["Farm radar"] = "Фарм радар"
L["It's recommended to enable shrinking the minimap when enabling this"] = "Рекомендуется включить сжатие миникарты при включении этого"
L["show addon node tooltips"] = "показать всплывающие подсказки добычи"
L["show GatherMate nodes"] = "показать места из GatherMate"
L["show HandyNotes pins"] = "показать точки HandyNotes"
L["shrink minimap to radar size"] = "уменьшить миникарту до размера радара"
L["This will block all mouseovers under the minimap in farm mode!"] = "Это заблокирует все указатели мыши под миникартой в режиме фарма!"
L["Toggle farming radar"] = "Переключить фарм радар"

-- Items
L["always show focused items"] = "Всегда показывать предметы из списка"
L["always show quest items"] = "Всегда показывать предметы для заданий"
L["always show reagents"] = "Всегда показывать реагенты"
L["always show recipes"] = "Всегда показывать рецепты"
L["focused item ids:"] = "Список id предметов"
L["icon scale"] = "Масштаб иконки"
L["Items"] = "предметы"
L["minimum"] = "минимум"
L["minimum rarity"] = "Минимальное качество"
L["only show focused items"] = "Показывать только предметы из списка"
L["show bag count for stackable items"] = "Показать количество собранных предметов в сумках"
L["show items based on rarity"] = "Показывать добычу на основе качества"
L["show total count for stackable items"] = "Показывать общее количество каждого из собранных предметов"

-- Minimap
L["display vignettes that appear on the minimap"] = "Отображать значки, которые появляются на миникарте"
L["Minimap"] = "Миникарта"

-- Misc
L["enable fast autoloot"] = "Включить быструю автодобычу"
L["hide health bars while fishing"] = "Скрыть бары здоровья во время рыбалки"
L["hide loot and item roll toasts"] = "Скрыть добычу со всплывающими окнами"
L["Misc"] = "Разное"

-- Money
L["Money"] = "Деньги"
L["Money counter was reset"] = "Счетчик денег был сброшен"
L["Money earned this session: "] = "Собранные деньги за эту сессию"
L["Money lost this session: "] = "Потраченные деньги за эту сессию:"
L["show money"] = "Показывать деньги"

-- Professions
L["Professions"] = "Профессии"
L["show profession levelups"] = "показать повышение уровня профессии"

-- Reputation
L["Reputation"] = "Репутация"
L["show reputation"] = "Показывать репутацию"

-- Sell and Repair
L["allow using guild funds for autorepair"] = "разрешить использовать средства гильдии для авторемонта"
L["autorepair when visiting merchants"] = "авторемонт при посещении торговцев"
L["autosell gray items when visiting merchants"] = "автопродажа серых предметов при посещении торговцев"
L["Equipment has been repaired by your guild for %s"] = "Экипировка отремонтирована за счет вашей гильдией на %s"
L["Equipment has been repaired for %s"] = "Экипировка была отремонтирована на %s"
L["Not enough gold for repairing your gear"] = "Недостаточно золота для ремонта вашего снаряжения"
L["Sell and Repair"] = "Продать и отремонтировать"
L["Selling gray items for %s"] = "Продажа серых предметов для %s"
L["skip readable items when autoselling"] = "пропускать читаемые предметы при автопродаже"

-- Skills
L["show skill levelups"] = "Показывать уровень профессий и навыков"
L["Skills"] = "Навыки"
