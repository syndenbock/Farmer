local _, addon = ...;

if (_G.C_TradeSkillUI == nil) then
  addon.registerUnavailableDetector('professions');
  return;
end

addon.registerAvailableDetector('professions');

local TradeSkillUI = _G.C_TradeSkillUI;
local GetAllProfessionTradeSkillLines = TradeSkillUI.GetAllProfessionTradeSkillLines;
local GetProfessionInfoBySkillLineID = TradeSkillUI.GetProfessionInfoBySkillLineID ;

local ImmutableMap = addon.import('Factory/ImmutableMap');

local professionCache;

local function updateSkillLine (data, id)
  local info = GetProfessionInfoBySkillLineID(id);

  if (info.skillLevel ~= 0) then
    data[id] = info;
  end
end

local function readProfessionSkillLines ()
  local data = {};

  for _, id in ipairs(GetAllProfessionTradeSkillLines()) do
    updateSkillLine(data, id);
  end

  return data;
end

local function yellProfession (info, change)
  addon.yell('PROFESSION_CHANGED', ImmutableMap(info), change);
end

local function checkProfessionChange (id)
  local oldInfo = professionCache[id];
  local newInfo = GetProfessionInfoBySkillLineID(id);

  if (oldInfo ~= nil) then
    if (newInfo.skillLevel ~= oldInfo.skillLevel) then
      local change = newInfo.skillLevel - oldInfo.skillLevel;

      oldInfo.skillLevel = newInfo.skillLevel;
      yellProfession(oldInfo, change);
    end
  elseif (newInfo.skillLevel ~= 0) then
    professionCache[id] = newInfo;
    yellProfession(newInfo, newInfo.skillLevel);
  end
end

local function checkProfessions ()
  for _, id in ipairs(GetAllProfessionTradeSkillLines()) do
    checkProfessionChange(id);
  end
end

addon.onOnce('SKILL_LINES_CHANGED', function ()
  professionCache = readProfessionSkillLines();
  addon.on('CHAT_MSG_SKILL', checkProfessions);
end);

--##############################################################################
-- testing
--##############################################################################

addon.import('tests').profession = function (id)
  if (id) then
    yellProfession(GetProfessionInfoBySkillLineID(tonumber(id)), 1);
  else
    yellProfession(GetProfessionInfoBySkillLineID(171), 1);
    yellProfession(GetProfessionInfoBySkillLineID(2483), 1);
  end
end
