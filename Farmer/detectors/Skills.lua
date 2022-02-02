local _, addon = ...;

if (_G.GetSkillLineInfo == nil) then
  addon.registerUnavailableDetector('skills');
  return;
end

addon.registerAvailableDetector('skills');

local tinsert = _G.tinsert;
local GetNumSkillLines = _G.GetNumSkillLines;
local GetSkillLineInfo = _G.GetSkillLineInfo;
local ExpandSkillHeader = _G.ExpandSkillHeader;
local CollapseSkillHeader = _G.CollapseSkillHeader;

local ImmutableMap = addon.Factory.ImmutableMap;

local skillCache = {};

local function collapseExpandedHeaders (expandedHeaders)
  for x = #expandedHeaders, 1, -1 do
    CollapseSkillHeader(expandedHeaders[x]);
  end
end

local function iterateSkills (callback)
  local data = {};
  local numSkills = GetNumSkillLines();
  local expandedHeaders = {};
  local i = 1;

  while (i <= numSkills) do
    local info = {GetSkillLineInfo(i)};
    local isHeader = info[2];

    if (isHeader) then
      local isExpanded = info[3];

      if (not isExpanded) then
        tinsert(expandedHeaders, i);
        ExpandSkillHeader(i);
        numSkills = GetNumSkillLines();
      end
    else
      callback({
        name = info[1],
        rank = info[4],
        maxRank = info[7],
      });
    end

    i = i + 1;
  end

  collapseExpandedHeaders(expandedHeaders);

  return data;
end

local function initSkillCache ()
  iterateSkills(function (skillInfo)
    skillCache[skillInfo.name] = skillInfo;
  end);
end

local function yellSkill (skillInfo, change)
  addon.yell('SKILL_CHANGED', ImmutableMap(skillInfo), change);
end

local function checkSkills ()
  iterateSkills(function (skillInfo)
    local cachedInfo = skillCache[skillInfo.name];

    if (not cachedInfo) then
      skillCache[skillInfo.name] = skillInfo;
      yellSkill(skillInfo, skillInfo.rank);
    elseif (skillInfo.rank ~= cachedInfo.rank) then
      yellSkill(skillInfo, skillInfo.rank - cachedInfo.rank);
      cachedInfo.rank = skillInfo.rank;
    end
  end);
end

addon.onOnce('PLAYER_LOGIN', function ()
  initSkillCache();
  addon.on('CHAT_MSG_SKILL', checkSkills);
end);

addon.share('tests').skills = function ()
  yellSkill({
    name = 'testskill',
    rank = 2,
    maxRank = 20,
  }, 1);
end
