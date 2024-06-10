local _, addon = ...;

local TradeSkillUI = _G.C_TradeSkillUI;
local GetAllProfessionTradeSkillLines =
    TradeSkillUI and TradeSkillUI.GetAllProfessionTradeSkillLines;
local GetProfessionInfoBySkillLineID =
    TradeSkillUI and TradeSkillUI.GetProfessionInfoBySkillLineID;
local GetTradeSkillTexture = TradeSkillUI and TradeSkillUI.GetTradeSkillTexture;
local GetProfessions = _G.GetProfessions;
local GetProfessionInfo = _G.GetProfessionInfo;

if (GetAllProfessionTradeSkillLines == nil and GetProfessions == nil) then
  addon.registerUnavailableDetector('professions');
  return;
end

addon.registerAvailableDetector('professions');

local ImmutableMap = addon.import('Factory/ImmutableMap');

local professionCache = {};

--##############################################################################
--  common functions
--##############################################################################

local function yellProfession (info, change)
  if (info.icon == nil and GetTradeSkillTexture ~= nil) then
    info.icon = GetTradeSkillTexture(info.professionID);
  end

  addon.yell('PROFESSION_CHANGED', ImmutableMap(info), change);
end

local function checkProfessionChange (info)
  local oldInfo = professionCache[info.professionID];

  if (oldInfo ~= nil) then
    if (info.skillLevel ~= oldInfo.skillLevel) then
      local change = info.skillLevel - oldInfo.skillLevel;

      oldInfo.skillLevel = info.skillLevel;
      yellProfession(oldInfo, change);
    end
  elseif (info.skillLevel ~= 0) then
    professionCache[info.professionID] = info;
    yellProfession(info, info.skillLevel);
  end
end

--##############################################################################
-- subprofession handling
--##############################################################################

if (GetAllProfessionTradeSkillLines ~= nil) then
  local function readSubProfessions ()
    for _, id in ipairs(GetAllProfessionTradeSkillLines()) do
      local info = GetProfessionInfoBySkillLineID(id);

      -- Skipping parent professions as those just reflect the most up-to date
      -- subprofession
      if (info.parentProfessionID ~= nil and info.skillLevel ~= 0) then
        professionCache[id] = info;
      end
    end
  end

  local function checkProfessions ()
    for _, id in ipairs(GetAllProfessionTradeSkillLines()) do
      local info = GetProfessionInfoBySkillLineID(id);

      -- Skipping parent professions as those just reflect the most up-to date
      -- subprofession
      if (info.parentProfessionID ~= nil) then
        checkProfessionChange(info);
      end
    end
  end

  addon.onOnce('TRADE_SKILL_SHOW', function ()
    readSubProfessions();
    addon.on('CHAT_MSG_SKILL', checkProfessions);
  end);
end

--##############################################################################
-- consolidated profession handling
--##############################################################################

-- This is used in classic clients where the profession UI exists but
-- professions are not split into subprofessions yet
if (GetAllProfessionTradeSkillLines == nil and GetProfessions ~= nil) then
  local function getPackedProfessionInfo (parentId)
    local info = {GetProfessionInfo(parentId)};

    -- This needs to match the return table of GetProfessionInfoBySkillLineID
    return {
      profession = parentId,
      professionID = info[7];
      professionName = info[1];
      icon = info[2],
      skillLevel = info[3],
      maxSkillLevel = info[4],
      skillModifier = info[8],
      parentProfessionID = info[7],
      parentProfessionName = info[1],
    };
  end

  local function readParentProfessions ()
    for _, parentId in ipairs({GetProfessions()}) do
      local info = getPackedProfessionInfo(parentId);

      professionCache[info.professionID] = info;
    end
  end

  local function checkParentProfessions ()
    for _, parentId in ipairs({GetProfessions()}) do
      local info = getPackedProfessionInfo(parentId);

      checkProfessionChange(info);
    end
  end

  addon.onOnce('PLAYER_LOGIN', function ()
    readParentProfessions();
    addon.on('CHAT_MSG_SKILL', checkParentProfessions);
  end);
end

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
