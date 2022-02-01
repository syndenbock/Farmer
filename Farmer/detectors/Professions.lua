local _, addon = ...;

if (_G.C_TradeSkillUI == nil) then
  addon.registerUnavailableDetector('professions');
  return;
end

addon.registerAvailableDetector('professions');

local tinsert = _G.tinsert;
local TradeSkillUI = _G.C_TradeSkillUI;
local GetAllProfessionTradeSkillLines = TradeSkillUI.GetAllProfessionTradeSkillLines;
local GetTradeSkillLineInfoByID = TradeSkillUI.GetTradeSkillLineInfoByID;
local GetProfessions = _G.GetProfessions;
local GetProfessionInfo = _G.GetProfessionInfo;

local ImmutableMap = addon.Factory.ImmutableMap;

local PROFESSION_CATEGORIES;
local professionCache;

local function readProfessionSkillLine (data, id)
  local info = {GetTradeSkillLineInfoByID(id)};
  local parentId = info[5];

  --[[ If parentId is nil, the current line is the main profession.
       Because Blizzard apparently does not know how to properly code, this
       will return the same info as the classic category, so we skip it --]]
  if (not parentId) then return end

  if (not data[parentId]) then
    data[parentId] = {};
  end

  tinsert(data[parentId], id);
end

local function getProfessionCategories ()
  local skillList = GetAllProfessionTradeSkillLines();
  local data = {};

  for _, id in pairs(skillList) do
    readProfessionSkillLine(data, id);
  end

  return data;
end

local function readLearnedProfession (data, professionId)
  local info = {GetProfessionInfo(professionId)};
  local skillId = info[7];
  local icon = info[2];

  data[skillId] = icon;
end

local function getLearnedProfessions ()
  local professions = {GetProfessions()};
  local data = {};

  --[[ array may contain nil values, so we have to iterate as an object --]]
  for _, professionId in pairs(professions) do
    readLearnedProfession(data, professionId);
  end

  return data;
end

local function getSkillLineInfo (skillId, icon)
  local info = {GetTradeSkillLineInfoByID(skillId)};

  return {
    id = skillId,
    name = info[1],
    rank = info[2],
    maxRank = info[3],
    parentSkillId = info[5],
    icon = icon,
  };
end

local function readSkillLineInfo (data, skillId, icon)
  data[skillId] = getSkillLineInfo(skillId, icon);
end

local function readProfessionCategoryInfo (data, professionId, icon)
  local skillList = PROFESSION_CATEGORIES[professionId];

  if (not skillList) then return end

  for _, skill in ipairs(skillList) do
    readSkillLineInfo(data, skill, icon);
  end
end

local function getLearnedProfessionInfo ()
  local learnedProfessions = getLearnedProfessions();
  local data = {};

  for professionId, icon in pairs(learnedProfessions) do
    readProfessionCategoryInfo(data, professionId, icon);
  end

  return data;
end

local function yellProfession (info, change)
  addon.yell('PROFESSION_CHANGED', ImmutableMap(info), change);
end

local function checkProfessionChange (id, info)
  local oldInfo = professionCache[id] or {};
  local change = info.rank - (oldInfo.rank or 0);

  if (change ~= 0) then
    yellProfession(info, change);
  end
end

local function checkProfessions ()
  local data = getLearnedProfessionInfo();

  for id, info in pairs(data) do
    checkProfessionChange(id, info);
  end

  professionCache = data;
end

addon.onOnce('PLAYER_LOGIN', function ()
  PROFESSION_CATEGORIES = getProfessionCategories();
  professionCache = getLearnedProfessionInfo();
  addon.on('CHAT_MSG_SKILL', checkProfessions);
end);

--##############################################################################
-- testing
--##############################################################################

addon.share('tests').profession = function (id)
  id = (id and tonumber(id)) or 171;

  yellProfession(getSkillLineInfo(id), 1);
end
