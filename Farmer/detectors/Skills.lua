local addonName, addon = ...;

if (not addon:isClassic()) then return end

local MESSAGE_COLORS = {0.9, 0.3, 0};
local professionCache = nil;

local function getProfessionInfo ()
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
        expandedHeaders[#expandedHeaders + 1] = i;
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

  for i = #expandedHeaders, 1, -1 do
    CollapseSkillHeader(expandedHeaders[i]);
  end

  return data;
end

local function checkProfessionData ()
  local data = getProfessionInfo();

  for name, info in pairs(data) do
    local oldInfo = professionCache[name] or {};
    local change = info.rank - (oldInfo.rank or 0);

    if (change ~= 0) then
      addon:yell('SKILL_CHANGED', name, change, info.rank, info.maxRank);
    end
  end

  professionCache = data;
end

addon:on('CHAT_MSG_SKILL', function ()
  if (professionCache == nil) then return end

  checkProfessionData();
end);

addon:on('PLAYER_LOGIN', function ()
  professionCache = getProfessionInfo();
end);
