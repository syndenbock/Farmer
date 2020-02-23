local addonName, addon = ...;

local PROFESSION_CATEGORIES;
local professionCache = nil;

local function getProfessionCategories ()
  local skillList = C_TradeSkillUI.GetAllProfessionTradeSkillLines();
  local data = {};

  for index, id in pairs(skillList) do
    local info = {C_TradeSkillUI.GetTradeSkillLineInfoByID(id)};
    local parentId = info[5];

    --[[ If parentId is nil, the current line is the main profession.
         Because Blizzard apparently does not know how to properly code, this
         will return the same info as the classic category, so we skip it --]]
    if (parentId ~= nil) then
      local list = data[parentId];

      if (list == nil) then
        data[parentId] = {id};
      else
        list[#list + 1] = id;
      end
    end
  end

  return data;
end

local function getLearnedProfessions ()
  local data = {};
  local professions = {GetProfessions()};

  --[[ array may contain nil values, so we have to iterate as an object --]]
  for _, professionId in pairs(professions) do
    local info = {GetProfessionInfo(professionId)};
    local skillId = info[7];

    data[skillId] = {
      icon = info[2]
    };
  end

  return data;
end

local function getProfessionInfo ()
  local learnedProfessions = getLearnedProfessions();
  local data = {};

  for parentId, parentInfo in pairs(learnedProfessions) do
    local skillList = PROFESSION_CATEGORIES[parentId];

    if (skillList ~= nil) then
      for i = 1, #skillList, 1 do
        local skillId = skillList[i];
        local info = {C_TradeSkillUI.GetTradeSkillLineInfoByID(skillId)};

        data[skillId] = {
          name = info[1],
          rank = info[2],
          maxRank = info[3],
          icon = parentInfo.icon,
        };
      end
    -- else
      -- print(parentId);
      -- print('A PARENT WAS EMPTY, HELP!!!');
    end
  end

  return data;
end

addon:on('CHAT_MSG_SKILL', function ()
  if (professionCache == nil) then return end

  local data = getProfessionInfo();

  if (not farmerOptions.skills) then
    professionCache = data;
    return;
  end

  for id, info in pairs(data) do
    local oldInfo = professionCache[id] or {};
    local change = info.rank - (oldInfo.rank or 0);

    if (change ~= 0) then
      addon:yell('PROFESSION_CHANGED', id, change, info.name, info.icon, info.rank, info.maxRank);
    end
  end

  professionCache = data;
end);

addon:on('PLAYER_LOGIN', function ()
  PROFESSION_CATEGORIES = getProfessionCategories();
  professionCache = getProfessionInfo();
end);
