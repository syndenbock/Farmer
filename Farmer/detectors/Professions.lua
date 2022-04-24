local _, addon = ...;

if (_G.C_TradeSkillUI == nil) then
  addon.registerUnavailableDetector('professions');
  return;
end

addon.registerAvailableDetector('professions');

local TradeSkillUI = _G.C_TradeSkillUI;
local GetAllProfessionTradeSkillLines = TradeSkillUI.GetAllProfessionTradeSkillLines;
local GetTradeSkillLineInfoByID = TradeSkillUI.GetTradeSkillLineInfoByID;

local ImmutableMap = addon.Factory.ImmutableMap;

local professionCache;

local function getPackedTradeSkillInfo (id)
  local info = {GetTradeSkillLineInfoByID(id)};

  return {
    id = id,
    name = info[1],
    rank = info[2],
    maxRank = info[3],
    modifier = info[4],
    parent = info[5],
  };
end

local function readProfessionSkillLines ()
  local data = {};

  for _, id in ipairs(GetAllProfessionTradeSkillLines()) do
    data[id] = getPackedTradeSkillInfo(id);
  end

  return data;
end

local function yellProfession (info, change)
  addon.yell('PROFESSION_CHANGED', ImmutableMap(info), change);
end

local function checkProfessionChange (id)
  local oldInfo = professionCache[id];
  local rank = select(2, GetTradeSkillLineInfoByID(id));

  if (rank ~= oldInfo.rank) then
    local change = rank - oldInfo.rank;

    oldInfo.rank = rank;
    yellProfession(oldInfo, change);
  end
end

local function checkProfessions ()
  for _, id in ipairs(GetAllProfessionTradeSkillLines()) do
    checkProfessionChange(id);
  end
end

addon.onOnce('PLAYER_LOGIN', function ()
  professionCache = readProfessionSkillLines();
  addon.on('CHAT_MSG_SKILL', checkProfessions);
end);

--##############################################################################
-- testing
--##############################################################################

addon.export('tests/profession', function (id)
  id = (id and tonumber(id)) or 171;

  yellProfession(getPackedTradeSkillInfo(id), 1);
end);
