local _, addon = ...;

-- This is the wackiest feature detection check I had to add so far, but because
-- Blizzard uses the same client for all Classic flavours, even deprecated APIs
-- and frames exist. You can even still display the skill frame in Cata Classic
-- using /run SkillFrame:Show(). Therefor this abomination is the best check I
-- found. If you find a better way of checking if the skill system exists,
-- please let me know!

if (GetSkillLineInfo == nil
    or CHARACTERFRAME_SUBFRAMES == nil
    or not tContains(CHARACTERFRAME_SUBFRAMES , 'SkillFrame')) then
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

    if (info[1] == nil) then
      addon.printOneTimeMessage('Could not check skills as another addon seems to be interfering with the skills pane');
    end

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
  skillCache[name] = rank;
end

local function initSkillCache ()
  iterateSkills(cacheSkillInfo);
end

local function yellSkill (skillInfo)
  addon.yell('SKILL_CHANGED', ImmutableMap(skillInfo));
end

local function checkSkill (name, rank, maxRank)
  if (skillCache[name] ~= rank) then
    yellSkill({
      name = name,
      rank = rank,
      maxRank = maxRank,
      rankChange = rank - (skillCache[name] or 0),
    });
    cacheSkillInfo(name, rank, maxRank);
  end
end

local function checkSkills ()
  iterateSkills(checkSkill);
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
    rankChange = 1,
  });
end;
