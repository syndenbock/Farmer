local addonName, addon = ...;

if (not addon.isDetectorAvailable('items')) then return end

local tinsert = _G.tinsert;
local strsplit = _G.strsplit;

local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS;

local L = addon.L;

local panel = addon.import('Class/Options/Panel'):new(L['Items'], addon.mainPanel);

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
      showEquipmentItemLevels = true,
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
  local itemId = tonumber(line);

  if (itemId ~= nil) then
    list[itemId] = true;
  end
end

local function parseItemIds (text)
  local list = {};

  text = {strsplit('\n', text)};

  for _, line in ipairs(text) do
    parseItemIdLine(list, line);
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
    showTotalCount = panel:addCheckBox(L['show total count for items']);
    showBagCount = panel:addCheckBox(L['show bag count for items']);
    showEquipmentItemLevels = panel:addCheckBox(L['show item levels for equipment']);
    filterByRarity = panel:addCheckBox(L['show items based on rarity']),
    minimumRarity = createRaritySlider(),
    alwaysShowReagents = panel:addCheckBox(L['always show reagents']),
    alwaysShowQuestItems = panel:addCheckBox(L['always show quest items']),
    alwaysShowRecipes = panel:addCheckBox(L['always show recipes']),
    alwaysShowFocusItems = panel:addCheckBox(L['always show focused items']),
    onlyShowFocusItems = panel:addCheckBox(L['only show focused items']),
  });

  panel:addLabel(L['focused item ids:']);
  focusIdBox = panel:addEditBox(150, 180);

  panel:OnFirstLoad(function ()
    focusIdBox:SetText(stringifyItemIds(options.focusItems));
  end);

  panel:OnSave(function ()
    options.focusItems = parseItemIds(focusIdBox:GetText());
  end);
end
