local addonName, addon = ...;

local tinsert = _G.tinsert;
local strtrim = _G.strtrim;

local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS;

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Items'], addon.mainPanel);
local focusIdBox;

local options = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
  farmerOptions = {
    rarity = true,
    minimumRarity = 2,
    reagents = true,
    questItems = true,
    recipes = false,
    special = true,
    focus = false,
    focusItems = {},
  },
}).vars.farmerOptions;

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
  local slider = panel:addSlider(0, 8, L['minimum rarity'], '', '', 1);

  slider:OnChange(function (self, value)
    displayRarity(self.edit, value);
  end);

  return slider;
end

local function initPanel ()
  panel:mapOptions({
    rarity = panel:addCheckBox(L['show items based on rarity']),
    minimumRarity = createRaritySlider(),
    reagents = panel:addCheckBox(L['always show reagents']),
    questItems = panel:addCheckBox(L['always show quest items']),
    recipes = panel:addCheckBox(L['always show recipes']),
    special = panel:addCheckBox(L['always show focused items']),
    focus = panel:addCheckBox(L['only show focused items']),
  });

  panel:addLabel(L['focused item ids:']);
  focusIdBox = panel:addEditBox(150, 240);
end

initPanel();

panel:OnLoad(function ()
  focusIdBox:SetText(stringifyItemIds(options.focusItems));
end);

panel:OnSave(function ()
  options.focusItems = parseItemIds(focusIdBox:GetText());
end);
