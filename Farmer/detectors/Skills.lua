local _, addon = ...;

if (not addon.isClassic()) then return end

local tinsert = _G.tinsert;
local GetNumSkillLines = _G.GetNumSkillLines;
local GetSkillLineInfo = _G.GetSkillLineInfo;
local ExpandSkillHeader = _G.ExpandSkillHeader;
local CollapseSkillHeader = _G.CollapseSkillHeader;

local skillCache;

local function collapseExpandedHeaders (expandedHeaders)
  for x = #expandedHeaders, 1, -1 do
    CollapseSkillHeader(expandedHeaders[x]);
  end
end

local function getSkillInfo ()
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
      local name = info[1];

      data[name] = {
        name = name,
        rank = info[4],
        maxRank = info[7],
      };
    end

    i = i + 1;
  end

  collapseExpandedHeaders(expandedHeaders);

  return data;
end

local function checkSkillChange (skillName, skillInfo)
  local oldInfo = skillCache[skillName] or {};
  local change = skillInfo.rank - (oldInfo.rank or 0);

  if (change == 0) then return end

  addon.yell('SKILL_CHANGED', skillName, change, skillInfo.rank,
      skillInfo.maxRank);
end

local function checkSkills ()
  local data = getSkillInfo();

  for name, info in pairs(data) do
    checkSkillChange(name, info);
  end

  skillCache = data;
end

addon.on('CHAT_MSG_SKILL', function ()
  if (not skillCache) then return end

  checkSkills();
end);

addon.on('PLAYER_LOGIN', function ()
  skillCache = getSkillInfo();
end);
