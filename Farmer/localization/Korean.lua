local _, addon = ...

if (_G.GetLocale() ~= 'koKR') then return end

local L = addon.L;

L["unknown command"] = "알 수 없는 명령어"
L[ [=[You seem to have used an old Version of Farmer
Check out all the new features in the options!]=] ] = "이전 버전의 Farmer를 사용한 것 같습니다. 설정의 모든 새로운 기능을 확인하세요!"

-- Currencies
L["Currencies"] = "화폐"
L["ignore Honor"] = "명예 무시"
L["show currencies"] = "화폐 표시"

-- Display
L["always show names"] = "항상 이름 표시"
L["center"] = "가운데"
L["display time"] = "표시 시간"
L["don't display at mailboxes"] = "우편함에서 표시하지 않기"
L["don't display in arena"] = "투기장에서 표시하지 않기"
L["down"] = "아래"
L["font size"] = "글꼴 크기"
L["grow direction"] = "성장 방향"
L["left"] = "왼쪽"
L["line spacing"] = "줄 간격"
L["Monochrome"] = "단색"
L["move display"] = "보여줄 곳 이동"
L["None"] = "없음"
L["outline mode"] = "외곽선 양식"
L["reset position"] = "위치 재설정"
L["right"] = "오른쪽"
L["text alignment"] = "문자 정렬"
L["Thick"] = "두껍게"
L["Thick Monochrome"] = "두꺼운 단색"
L["Thin"] = "얇게"
L["up"] = "위"

-- Experience
L["Experience"] = "경험치"
L["minimum %"] = "최소 %"
L["show experience"] = "경험치 표시"

-- Farm radar
L["enable tooltips for default nodes"] = "기본 노드용 툴팁 켜기"
L["Farm radar"] = "파밍 레이더"
L["show addon node tooltips"] = "애드온 노드용 툴팁 켜기"
L["shrink minimap to radar size"] = "미니맵을 레이더 ​​크기로 축소"
L["Toggle farming radar"] = "파밍 레이더 켜고 끄기"

-- Items
L["always show focused items"] = "항상 주시하는 아이템 표시"
L["always show quest items"] = "항상 퀘스트 아이템 표시"
L["always show reagents"] = "항상 재료 표시"
L["always show recipes"] = "항상 제조법 표시"
L["focused item ids:"] = "주시하는 아이템 ID:"
L["icon scale"] = "아이콘 크기 비율"
L["Items"] = "아이템"
L["minimum"] = "최소"
L["minimum rarity"] = "최소 품질"
L["only show focused items"] = "주시하는 아이템 만 표시"
L["show bag count for items"] = "겹쳐지는 아이템의 가방 내의 개수 표시"
L["show item levels for equipment"] = "장비 아이템 레벨 표시"
L["show items based on rarity"] = "품질을 기준으로 아이템 표시"
L["show total count for items"] = "아이템 총수 표시"

-- Minimap
L["display vignettes that appear on the minimap"] = "미니맵에 나타나는 작은 아이콘 표시"
L["Minimap"] = "미니맵"

-- Misc
L["enable fast autoloot"] = "빠른 자동 전리품 획득 사용"
L["hide health bars while fishing"] = "낚시하는 동안 생명력 바 숨김"
L["hide loot and item roll toasts"] = "전리품과 아이템 주사위 굴리기 숨김"
L["Misc"] = "기타"

-- Money
L["Money"] = "골드"
L["Money counter was reset"] = "골드 카운터가 초기화되었습니다."
L["Money earned this session: "] = "이번 접속에서 얻은 골드:"
L["Money lost this session: "] = "이번 접속에서 잃은 골드:"
L["show money"] = "골드 표시"

-- Professions
L["Professions"] = "전문 기술"
L["show profession levelups"] = "전문 기술 레벨업 표시"

-- Reputation
L["Reputation"] = "평판"
L["show reputation"] = "평판 표시"

-- Sell and Repair
L["allow using guild funds for autorepair"] = "자동 수리에 길드 자금 사용 허용"
L["autorepair when visiting merchants"] = "상인 방문 시 자동 수리"
L["autosell gray items when visiting merchants"] = "상인 방문 시 회색 아이템 자동 판매"
L["Equipment has been repaired by your guild for %s"] = "길드 자금 %s로 장비를 수리했습니다."
L["Equipment has been repaired for %s"] = "장비를 %s로 수리했습니다."
L["Not enough gold for repairing your gear"] = "장비 수리를 위한 골드가 부족합니다."
L["Sell and Repair"] = "판매 및 수리"
L["Selling gray items for %s"] = "회색 아이템을 %s에 판매합니다."
L["skip readable items when autoselling"] = "자동 판매 시 읽을 수 있는 아이템 건너뛰기"

-- Skills
L["show skill levelups"] = "기술 레벨 상승 표시"
