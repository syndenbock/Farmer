local _, addon = ...

if (_G.GetLocale() ~= 'zhCN') then return end

local L = addon.L;

L["unknown command"] = "未知的命令"
L[ [=[You seem to have used an old Version of Farmer
Check out all the new features in the options!]=] ] = "你似乎用了旧版本的Farmer插件,到选项中查看所有的新特性!"

-- Currencies
L["ignore Honor"] = "忽略荣誉"
L["show currencies"] = "显示货币"

-- Display
L["always show names"] = "显示所有物品名称"
L["display time"] = "显示持续时间"
L["don't display at mailboxes"] = "使用邮箱时不显示"
L["don't display in arena"] = "在竞技场不显示"
L["font size"] = "字体大小"
L["Monochrome"] = "黑白描边"
L["move display"] = "拖移显示位置"
L["None"] = "无"
L["outline mode"] = "文字描边的模式"
L["reset position"] = "重置位置"
L["Thick"] = "粗描边"
L["Thick Monochrome"] = "黑白粗式描边"
L["Thin"] = "细描边"

-- Experience

-- Farm radar

-- Items
L["always show focused items"] = "总是显示被关注的物品"
L["always show quest items"] = "总是显示任务物品"
L["always show reagents"] = "总是显示试剂"
L["always show recipes"] = "总是显示食谱"
L["focused item ids:"] = "输入关注物品的id:"
L["icon scale"] = "图标缩放"
L["minimum rarity"] = "最小显示品质"
L["only show focused items"] = "只显示被关注的物品"
L["show bag count for items"] = "显示背包中可堆叠物品的数量"
L["show items based on rarity"] = "根据物品品质来显示"
L["show total count for items"] = "显示可堆叠物品的总数量(包含银行)"

-- Minimap

-- Misc
L["enable fast autoloot"] = "允许快速自动拾取"
L["hide health bars while fishing"] = "钓鱼时隐藏生命条"
L["hide loot and item roll toasts"] = "隐藏掷筛和拾取的窗口信息"

-- Money
L["Money counter was reset"] = "金钱计数已经重置"
L["Money earned this session: "] = "这段时间获取的金钱数:"
L["Money lost this session: "] = "这段时间失去的金钱数:"
L["show money"] = "显示金钱拾取"

-- Professions

-- Reputation
L["show reputation"] = "显示声望获取"

-- Sell and Repair

-- Skills
L["show skill levelups"] = "显示技能点数提升"
