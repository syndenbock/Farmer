local _, addon = ...;

local C_SkillInfo = _G.C_SkillInfo or {};

addon.export('client/polyfills/C_SkillInfo', {
  GetNumSkillLines = C_SkillInfo.GetNumSkillLines or _G.GetNumSkillLines;
  GetSkillLineInfo = C_SkillInfo.GetSkillLineInfo or (_G.GetSkillLineInfo and function (...)
    local name, isHeader, isExpanded, rank, tempPoints,
        modifier, maxRank, isAbandonable, stepCost, rankCost,
        minLevel, costType, description = _G.GetSkillLineInfo(...);

    if not name then
        return nil
    end

    return {
        name = name,
        isHeader = isHeader == 1,
        isCollapsed = isHeader == 1 and isExpanded ~= 1,
        rank = rank,
        tempPoints = tempPoints,
        modifier = modifier,
        maxRank = maxRank,
        isAbandonable = isAbandonable == 1,
        stepCost = stepCost,
        rankCost = rankCost,
        minLevel = minLevel,
        costType = costType,
        description = description,
    }
  end);
  ExpandSkillHeader = C_SkillInfo.ExpandSkillHeader or _G.ExpandSkillHeader;
  CollapseSkillHeader = C_SkillInfo.CollapseSkillHeader or _G.CollapseSkillHeader;
});
