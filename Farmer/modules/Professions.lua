local addonName, addon = ...;

local MESSAGE_COLORS = {0.9, 0.3, 0};
local professionCache = nil;

local function getLearnedProfessions ()
  local data = {};
  local professions = {GetProfessions()};

  for i = 1, #professions, 1 do
    local info = {GetProfessionInfo(professions[i])};
    local skillId = info[7];

    data[skillId] = {
      icon = info[2]
    };
  end

  return data;
end

local function getProfessionInfo ()
  local learnedProfessions = getLearnedProfessions();
  local skillList = C_TradeSkillUI.GetAllProfessionTradeSkillLines();
  local data = {};

  for i = 1, #skillList, 1 do
    local id = skillList[i];
    local info = {C_TradeSkillUI.GetTradeSkillLineInfoByID(id)};
    local parentId = info[5];
    local parentInfo = learnedProfessions[parentId];

    if (parentInfo ~= nil) then
      data[id] = {
        name = info[1],
        rank = info[2],
        maxRank = info[3],
        icon = parentInfo.icon,
      };
    end
  end

  return data;
end

addon:on('SKILL_LINES_CHANGED', function ()
  if (professionCache == nil) then return end
  local data = getProfessionInfo();

  for id, info in pairs(data) do
    local oldInfo = professionCache[id] or {};
    local change = info.rank - (oldInfo.rank or 0);

    if (change ~= 0) then
      local icon = addon:getIcon(info.icon);
      local text = addon:stringJoin({'(', info.rank, '/', info.maxRank, ')'}, '');

      addon.Print.printMessage(addon:stringJoin({icon, info.name, text}, ' '), MESSAGE_COLORS);
    end
  end

  professionCache = data;
end);

addon:on('PLAYER_LOGIN', function ()
  professionCache = getProfessionInfo();
end);
