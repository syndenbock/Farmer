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

local ImmutableMap = addon.import('Factory/ImmutableMap');

local skillCache = {};

local function collapseExpandedHeaders (expandedHeaders)
  for x = #expandedHeaders, 1, -1 do
    CollapseSkillHeader(expandedHeaders[x]);
  end
end

local function iterateSkills (callback)
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
      callback(
        info[1], -- name
        info[4], -- rank
        info[7] --maxRank
      );
    end

    i = i + 1;
  end

  collapseExpandedHeaders(expandedHeaders);
end

local function cacheSkillInfo (name, rank, maxRank)
  skillCache[name] = {
    name = name,
    rank = rank,
    maxRank = maxRank,
  };
end

local function initSkillCache ()
  iterateSkills(cacheSkillInfo);
end

local function yellSkill (skillInfo, change)
  addon.yell('SKILL_CHANGED', ImmutableMap(skillInfo), change);
end

local function checkSkills ()
  iterateSkills(function (name, rank, maxRank)
    local cachedInfo = skillCache[name];

    if (cachedInfo == nil) then
      cacheSkillInfo(name, rank, maxRank);
      yellSkill(skillCache[name], rank);
    else
      if (cachedInfo.maxRank ~= maxRank) then
        cachedInfo.maxRank = maxRank;
      end

      if (cachedInfo.rank ~= rank) then
        local change = rank - cachedInfo.rank;

        cachedInfo.rank = rank;
        yellSkill(cachedInfo, change);
      end
    end
  end);
end

addon.onOnce('PLAYER_LOGIN', function ()
  initSkillCache();
  addon.on('CHAT_MSG_SKILL', checkSkills);
end);

addon.import('tests').skills = function ()
  yellSkill({
    name = 'testskill',
    rank = 2,
    maxRank = 20,
  }, 1);
end;
