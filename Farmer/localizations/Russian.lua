local addonName, addon = ...

if (GetLocale() ~= 'enUS') then return end

local L = addon.L;

L = L or {}
L["always show focused items"] = "Всегда показывать\nпредметы из списка"
L["always show quest items"] = "Всегда показывать предметы для заданий"
L["always show reagents"] = "Всегда показывать реагенты"
L["always show recipes"] = "Всегда показывать рецепты"
L["display time"] = "Время отображения"
L["don't display at mailboxes"] = "не показывать добычу из почтовых ящиков"
L["don't display in arena"] = "не показывать на арене"
L["don't display on island expeditions"] = "не показывать на островных экспедициях"
L["enable fast autoloot"] = "включить быструю автодобычу"
L["focused item ids:"] = "Список id предметов"
L["font size"] = "Размер шрифта"
L["hide health bars while fishing"] = "Скрыть бары здоровья во время рыбалки"
L["hide loot and item roll toasts"] = "скрыть добычу по роллу"
L["icon scale"] = "Масштаб иконки"
L["ignore Honor"] = "игнорировать честь"
L["minimum rarity"] = "Минимальное качество"
L["Money counter was reset"] = "Счетчик денег был сброшен"
L["Money earned this session: "] = "Собранные деньги за эту сессию"
L["Money lost this session: "] = "Потраченные деньги за эту сессию:"
L["move display"] = "Переместить текст"
L["only show focused items"] = "Показывать только\nпредметы из списка"
L["reset position"] = "Сбросить расположение"
L["show bag count for stackable items"] = "Показать количество собранных\nпредметов в сумках"
L["show currencies"] = "Показывать валюту"
L["show items based on rarity"] = "Показывать добычу на основе качества"
L["show money"] = "Показывать деньги"
L["show names of all items"] = "Показывать названия всех предметов"
L["show total count for stackable items"] = "Показывать общее количество\nкаждого из собранных предметов"
L["unknown command"] = "Неизвестная команда"
L["You seem to have used an old Version of Farmer\nCheck out all the new features in the options!"] = "Похоже, вы использовали старую версию Farmer\nПроверьте все новые функции в опциях!"
