local addonName, addon = ...;

local tinsert = _G.tinsert;
local strtrim = _G.strtrim;

local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS;

local L = addon.L;

local panel = addon.OptionClass.Panel:new(L['Items'], addon.mainPanel);

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    Items = {
      showBagCount = false,
      showTotalCount = true,
      filterByRarity = true,
      minimumRarity = 2,
      alwaysShowReagents = true,
      alwaysShowQuestItems = true,
      alwaysShowRecipes = false,
      alwaysShowFocusItems = true,
      onlyShowFocusItems = false,
      focusItems = {},
    },
  },
}).vars.farmerOptions.Items;

local function stringifyItemIds (map)
  local text = {};

  for key in pairs(map) do
    tinsert(text, key);
  end

  return table.concat(text, '\n');
end

local function parseItemIdLine (list, line)
  line = strtrim(line);

  if (line ~= '') then
    list[tonumber(line)] = true;
  end
end

local function parseItemIds (text)
  local list = {};

  text = {string.split('\n', text)};

  for x = 1, #text, 1 do
    parseItemIdLine(list, text[x]);
  end

  return list;
end

local function displayRarity (edit, rarity)
  local colorHex = ITEM_QUALITY_COLORS[rarity].hex;

  edit:SetText(colorHex .. _G['ITEM_QUALITY' .. rarity .. '_DESC'] .. '|r');
  edit:SetCursorPosition(0);
end

local function createRaritySlider ()
  local slider = panel:addSlider(0, 8, L['minimum rarity'], '', '', 0);

  slider:OnChange(function (self, value)
    displayRarity(self.edit, value);
  end);

  return slider;
end

do
  local focusIdBox;

  panel:mapOptions(options, {
    showTotalCount = panel:addCheckBox(L['show total count for stackable items']);
    showBagCount = panel:addCheckBox(L['show bag count for stackable items']);
    filterByRarity = panel:addCheckBox(L['show items based on rarity']),
    minimumRarity = createRaritySlider(),
    alwaysShowReagents = panel:addCheckBox(L['always show reagents']),
    alwaysShowQuestItems = panel:addCheckBox(L['always show quest items']),
    alwaysShowRecipes = panel:addCheckBox(L['always show recipes']),
    alwaysShowFocusItems = panel:addCheckBox(L['always show focused items']),
    onlyShowFocusItems = panel:addCheckBox(L['only show focused items']),
  });

  panel:addLabel(L['focused item ids:']);
  focusIdBox = panel:addEditBox(150, 200);

  panel:OnLoad(function ()
    focusIdBox:SetText(stringifyItemIds(options.focusItems));
  end);

  panel:OnSave(function ()
    options.focusItems = parseItemIds(focusIdBox:GetText());
  end);
end
