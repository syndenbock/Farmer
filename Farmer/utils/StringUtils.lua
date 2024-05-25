local addonName, addon = ...;

local strfind = _G.strfind;
local strsub = _G.strsub;
local strmatch = _G.strmatch;
local strjoin = _G.strjoin;
local tostring = _G.tostring;
local tinsert = _G.tinsert;
local floor = _G.floor;
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers;
local CreateAtlasMarkup = _G.CreateAtlasMarkup;
local COPPER_PER_GOLD = _G.COPPER_PER_GOLD;
local COPPER_PER_SILVER = _G.COPPER_PER_SILVER;
local SILVER_PER_GOLD = _G.SILVER_PER_GOLD;

local oneTimeMessages = {};

local TEXTURE_COPPER, TEXTURE_SILVER, TEXTURE_GOLD = (function ()
  local GetAtlasInfo = _G.C_Texture.GetAtlasInfo;

  local function getCoinTexture (atlas, fallback)
    return (GetAtlasInfo(atlas) and CreateAtlasMarkup(atlas)) or
        ('|TInterface\\MoneyFrame\\' .. fallback .. 'Icon:0:0:0:0|t');
  end

  return getCoinTexture('coin-copper', 'UI-Copper'),
    getCoinTexture('coin-silver', 'UI-Silver'),
    getCoinTexture('coin-gold', 'UI-Gold');
end)();

local ADDON_MESSAGE_PREFIX = '|cff00ffff' .. addonName .. '|r:';

function addon.createAddonMessage (...)
  return strjoin(' ', ADDON_MESSAGE_PREFIX, ...);
end

function addon.printAddonMessage (...)
  print(ADDON_MESSAGE_PREFIX, ...);
end

function addon.printOneTimeMessage (...)
  local message = strjoin(' ', ...);

  if (oneTimeMessages[message] == nil) then
    addon.printAddonMessage(message);
    oneTimeMessages[message] = true;
  end
end

function addon.stringStartsWith (string, check)
  return (string:sub(1, #check) == check);
end

function addon.stringEndsWith (string, check)
  return (check == "" or string:sub(-#check) == check);
end

function addon.stringJoin (joiner, ...)
  local result;

  for x = 1, select('#', ...), 1 do
    local fragment = select(x, ...);

    if (fragment ~= nil) then
      fragment = tostring(fragment);
      result = (result and result .. joiner .. fragment) or fragment;
    end
  end

  return result or '';
end

function addon.tableJoin (stringList, joiner)
  local result;

  joiner = joiner or '';

  --[[ use pairs instead of ipairs to not break on empty items ]]
  for _, fragment in pairs(stringList) do
    fragment = tostring(fragment);
    result = (result and result .. joiner .. fragment) or fragment;
  end

  return result or '';
end

function addon.replaceString (string, match, replacement)
  local startPos, endPos = strfind(string, match, 1, true);

  if (startPos) then
    return strsub(string, 1, startPos - 1) .. replacement .. strsub(string, endPos + 1);
  else
    return string;
  end
end

function addon.formatMoney (amount)
  local gold = floor(amount / COPPER_PER_GOLD);
  local silver = floor(amount / COPPER_PER_SILVER) % SILVER_PER_GOLD;
  local copper = amount % COPPER_PER_SILVER;
  local text = {};

  if (gold > 0) then
    tinsert(text, BreakUpLargeNumbers(gold) .. TEXTURE_GOLD);
  end

  if (silver > 0) then
    tinsert(text, BreakUpLargeNumbers(silver) .. TEXTURE_SILVER);
  end

  if (copper > 0 or #text == 0) then
    tinsert(text, BreakUpLargeNumbers(copper) .. TEXTURE_COPPER);
  end

  return addon.tableJoin(text, ' ');
end

function addon.findItemLink (string)
  return strmatch(string, '|c.+|h|r');
end

function addon.extractItemString (itemLink)
  return strmatch(itemLink, 'item[%-?%d:]+');
end

local craftedQualityIcons = {};

function addon.getCraftedQualityIcon (quality)
  if (craftedQualityIcons[quality] == nil) then
    craftedQualityIcons[quality] = CreateAtlasMarkup(('Professions-Icon-Quality-Tier%d-Small'):format(quality), nil, nil, nil, nil, nil);
  end

  return craftedQualityIcons[quality];
end

function addon.extractNormalizedItemString (itemLink)
  --[[ the 9th and 10th positions contain character level and spec, which causes
       different links after levelups or spec swaps and therefor have to be
       removed ]]
  local pattern = '.*(item:.-:.-:.-:.-:.-:.-:.-:.-:)(.-:.-:)([%-?%d:]*).*';
  local match = {strmatch(itemLink, pattern)};

  if (#match >= 3) then
    return strjoin('', match[1], '::', match[3]);
  else
    return nil;
  end
end
