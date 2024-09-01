local _, addon = ...

if (_G.GetLocale() ~= 'frFR') then return end

local L = addon.L;

L["unknown command"] = "Commande inconnue"
L[ [=[You seem to have used an old Version of Farmer
Check out all the new features in the options!]=] ] = "Vous semblez avoir utilisé une ancienne version de Farmer Découvrez toutes les nouvelles fonctionnalités dans les options!"

-- Currencies
L["Currencies"] = "Monnaies"
L["ignore Honor"] = "Ignorer l'Honneur"
L["show currencies"] = "Afficher les devises"

-- Display
L["always show names"] = "Toujours afficher les noms"
L["center"] = "Centrer"
L["display time"] = "Durée d'affichage"
L["don't display at mailboxes"] = "Ne pas afficher dans les boîtes aux lettres"
L["don't display in arena"] = "Ne pas afficher en Arènes"
L["down"] = "Vers le bas"
L["font size"] = "Taille de la police d'écriture"
L["grow direction"] = "Orientation de l'affichage "
L["left"] = "Vers la gauche"
L["line spacing"] = "Inter-ligne "
L["Monochrome"] = "Monochrome"
L["move display"] = "Déplacer l'affichage"
L["None"] = "Aucun"
L["outline mode"] = "Mode contour"
L["reset position"] = "Réinitialiser la position"
L["right"] = "Vers la droite"
L["text alignment"] = "Alignement du texte"
L["Thick"] = "Épais"
L["Thick Monochrome"] = "Épais monochrome"
L["Thin"] = "Mince"
L["up"] = "Vers le haut"

-- Experience
L["Experience"] = "Expérience"
L["minimum %"] = "minimum %"

-- Farm radar
L["enable tooltips for default nodes"] = "Activer les info-bulles pour les nœuds par défaut"
L["Farm radar"] = "Radar de farm"
L["It's recommended to enable shrinking the minimap when enabling this"] = "Il est recommandé d'activer la réduction de la minimap lors de l'activation de ceci"
L["show addon node tooltips"] = "Afficher les info-bulles des nœuds de l'addon"
L["shrink minimap to radar size"] = "Réduire la minimap à la taille du radar"
L["This will block all mouseovers under the minimap in farm mode!"] = "Bloquer tous les mouseovers sous la mini-carte en mode farm!"
L["Toggle farming radar"] = "Basculer le radar de farm"

-- Items
L["always show focused items"] = "Toujours afficher les objets ciblés"
L["always show quest items"] = "Toujours afficher les objets de quêtes"
L["always show reagents"] = "Toujours afficher les composants"
L["always show recipes"] = "Toujours afficher les recettes"
L["focused item ids:"] = "Identifiants des éléments ciblés:"
L["icon scale"] = "Échelle de l'icône"
L["Items"] = "Objets"
L["minimum"] = "Minimum"
L["minimum rarity"] = "Rareté minimum"
L["only show focused items"] = "Afficher uniquement les objets ciblés"
L["show bag count for items"] = "Afficher le nombre d'objets en sacs"
L["show items based on rarity"] = "Affichage des objets basé sur la rareté"
L["show total count for items"] = "Afficher le nombre total d'objets"

-- Minimap
L["display vignettes that appear on the minimap"] = "Afficher les icônes sur la minimap"
L["Minimap"] = "Minimap"

-- Misc
L["enable fast autoloot"] = "Activer la fouille automatique rapide"
L["hide health bars while fishing"] = "Masquer la barre de vie lors de la pêche "
L["Misc"] = "Divers"

-- Money
L["Money"] = "Monnaie"
L["Money counter was reset"] = "Le compteur de Monnaie a été réinitialisé"
L["Money earned this session: "] = "Monnaie gagné pendant cette cession:"
L["Money lost this session: "] = "Monnaie perdu pendant cette cession:"
L["show money"] = "Afficher la Monnaie"

-- Professions
L["Professions"] = "Professions"
L["show profession levelups"] = "Afficher les niveaux gagnés dans les métiers"

-- Reputation
L["Reputation"] = "Réputation"
L["show reputation"] = "Afficher la réputation"

-- Sell and Repair
L["allow using guild funds for autorepair"] = "Autoriser l'utilisation des fonds de Guilde pour l’auto-réparation "
L["autorepair when visiting merchants"] = "Auto-réparation lors des visites aux marchands"
L["autosell gray items when visiting merchants"] = "Vente automatique des objets gris lors des visites aux marchands"
L["Equipment has been repaired by your guild for %s"] = "L'équipement à été réparé à %s par votre Guilde"
L["Equipment has been repaired for %s"] = "L'équipement à été réparé à %s"
L["Not enough gold for repairing your gear"] = "Pas assez d'or pour réparer votre équipement"
L["Sell and Repair"] = "Vendre et réparer"
L["Selling gray items for %s"] = "Vendre les objets gris à %s"
L["skip readable items when autoselling"] = "Ignorer les objets lisibles lors de la vente automatique"

-- Skills
L["show skill levelups"] = "Afficher les niveaux de compétences gagnés"
L["Skills"] = "Compétences"
