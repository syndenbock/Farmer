local _, addon = ...

if (_G.GetLocale() ~= 'ptBR') then return end

local L = addon.L;

L["unknown command"] = "Comando desconhecido"
L[ [=[You seem to have used an old Version of Farmer
Check out all the new features in the options!]=] ] = "Parece que você usou uma versão antiga do Farmer Confira todos os novos recursos nas opções!"

-- Currencies
L["Currencies"] = "Moedas"
L["ignore Honor"] = "ignorar Honra"
L["show currencies"] = "mostrar moedas"

-- Display
L["always show names"] = "sempre mostrar nomes"
L["center"] = "Centro"
L["display time"] = "tempo de exibição"
L["don't display at mailboxes"] = "não exibir nas caixas de correio"
L["don't display in arena"] = "não exibir na arena"
L["down"] = "abaixo"
L["font size"] = "tamanho da fonte"
L["grow direction"] = "crescer direção"
L["left"] = "esquerda"
L["line spacing"] = "espaçamento entre linhas"
L["Monochrome"] = "Monocromático"
L["move display"] = "mover exibição"
L["None"] = "Nenhum"
L["outline mode"] = "modo de contorno"
L["reset position"] = "redefinir posição"
L["right"] = "direita"
L["text alignment"] = "alinhamento de texto"
L["Thick"] = "Espesso"
L["Thick Monochrome"] = "Monocromático espesso"
L["Thin"] = "Fino"
L["up"] = "acima"

-- Experience
L["Experience"] = "Experiência"
L["minimum %"] = "mínimo %"
L["show experience"] = "mostrar experiência"

-- Farm radar
L["enable tooltips for default nodes"] = "habilitar dicas de ferramentas para nós padrão"
L["Farm radar"] = "Radar de farm"
L["It's recommended to enable shrinking the minimap when enabling this"] = "Recomenda-se habilitar a redução do minimapa ao habilitar isso"
L["show addon node tooltips"] = "habilitar dicas de ferramentas para nós de complemento"
L["shrink minimap to radar size"] = "encolher minimapa para o tamanho do radar"
L["This will block all mouseovers under the minimap in farm mode!"] = "Isso bloqueará todos os mouseovers sob o minimapa enquanto estiver no modo de farm!"
L["Toggle farming radar"] = "Alternar radar de farm"

-- Items
L["always show focused items"] = "sempre mostrar itens focados"
L["always show quest items"] = "sempre mostrar itens de missão"
L["always show reagents"] = "sempre mostrar reagentes"
L["always show recipes"] = "sempre mostrar receitas"
L["focused item ids:"] = "IDs de itens focados:"
L["icon scale"] = "escala de ícone"
L["Items"] = "Items"
L["minimum"] = "mínimo"
L["minimum rarity"] = "raridade mínima"
L["only show focused items"] = "mostrar apenas itens focados"
L["show bag count for items"] = "mostrar contagem de sacos para itens"
L["show item levels for equipment"] = "mostrar níveis de itens para equipamentos"
L["show items based on rarity"] = "mostrar itens com base na raridade"
L["show total count for items"] = "mostrar a contagem total de itens"

-- Minimap
L["display vignettes that appear on the minimap"] = "exibir vinhetas que aparecem no minimapa"
L["Minimap"] = "Minimapa"

-- Misc
L["enable fast autoloot"] = "habilitar saque automático rápido"
L["hide health bars while fishing"] = "esconder barras de saúde enquanto pesca"
L["Misc"] = "Diversos"

-- Money
L["Money"] = "Dinheiro"
L["Money counter was reset"] = "O contador de dinheiro foi redefinido"
L["Money earned this session: "] = "Dinheiro ganho nesta sessão:"
L["Money lost this session: "] = "Dinheiro perdido nesta sessão:"
L["show money"] = "mostrar dinheiro"

-- Professions
L["Professions"] = "Profissões"
L["show profession levelups"] = "mostrar níveis de profissão"

-- Reputation
L["Reputation"] = "Reputação"
L["show reputation"] = "mostrar reputação"

-- Sell and Repair
L["allow using guild funds for autorepair"] = "permitir o uso de fundos da guilda para reparo automático"
L["autorepair when visiting merchants"] = "reparo automático ao visitar comerciantes"
L["autosell gray items when visiting merchants"] = "venda automática de itens cinza ao visitar comerciantes"
L["Equipment has been repaired by your guild for %s"] = "O equipamento foi consertado por sua guilda por %s"
L["Equipment has been repaired for %s"] = "O equipamento foi consertado por %s"
L["Not enough gold for repairing your gear"] = "Não há ouro suficiente para consertar seu equipamento"
L["Sell and Repair"] = "Vender e Reparar"
L["Selling gray items for %s"] = "Vendendo itens cinza para %s"
L["skip readable items when autoselling"] = "pular itens legíveis ao vender automaticamente"

-- Skills
L["show skill levelups"] = "mostrar níveis de habilidade"
L["Skills"] = "Habilidades"
