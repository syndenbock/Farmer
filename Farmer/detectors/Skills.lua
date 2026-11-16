local _, addon = ...;

-- This is the wackiest feature detection check I had to add so far, but because
-- Blizzard uses the same client for all Classic flavours, even deprecated APIs
-- and frames exist. You can even still display the skill frame in Cata Classic
-- using /run SkillFrame:Show(). Therefor this abomination is the best check I
-- found. If you find a better way of checking if the skill system exists,
-- please let me know!

local C_SkillInfo = addon.import("client/polyfills/C_SkillInfo");

if (C_SkillInfo.GetSkillLineInfo == nil) then
  addon.registerUnavailableDetector('skills');
  return;
end

local tinsert = _G.tinsert;
local GetNumSkillLines = C_SkillInfo.GetNumSkillLines;
local GetSkillLineInfo = C_SkillInfo.GetSkillLineInfo;
local ExpandSkillHeader = C_SkillInfo.ExpandSkillHeader;
local CollapseSkillHeader = C_SkillInfo.CollapseSkillHeader;

local ImmutableMap = addon.import('core/classes/Maps').ImmutableMap;
local Events = addon.import('core/logic/Events');
local Yell = addon.import('core/logic/Yell');

addon.registerAvailableDetector('skills');

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
    local info = GetSkillLineInfo(i);

    if (info ~= nil) then
      if (info.isHeader) then
        if (info.isCollapsed) then
          tinsert(expandedHeaders, i);
          ExpandSkillHeader(i);
          numSkills = GetNumSkillLines();
        end
      else
        callback(info);
      end
    end

    i = i + 1;
  end

  collapseExpandedHeaders(expandedHeaders);
end

local function cacheSkillInfo (skillInfo)
  skillCache[skillInfo.name] = skillInfo.rank;
end

local function initSkillCache ()
  iterateSkills(cacheSkillInfo);
end

local function yellSkill (skillInfo)
  Yell.yell('SKILL_CHANGED', ImmutableMap(skillInfo));
end

local function checkSkill (skillInfo)
  if (skillCache[skillInfo.name] ~= skillInfo.rank) then
    yellSkill({
      name = skillInfo.name,
      rank = skillInfo.rank,
      maxRank = skillInfo.maxRank,
      rankChange = skillInfo.rank - (skillCache[skillInfo.name] or 0),
    });
    cacheSkillInfo(skillInfo);
  end
end

local function checkSkills ()
  iterateSkills(checkSkill);
end

Events.onOnce('PLAYER_LOGIN', function ()
  initSkillCache();
  Events.on('CHAT_MSG_SKILL', checkSkills);
end);

local Tests = addon.import('core/logic/Tests');

Tests.addTest('skills', function ()
  yellSkill({
    name = 'testskill',
    rank = 2,
    maxRank = 20,
    rankChange = 1,
  });
end);
