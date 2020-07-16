local addonName, addon = ...;

local tinsert = _G.tinsert;
local strtrim = _G.strtrim;

local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS;

local L = addon.L;

local panel = addon.OptionFactory.Panel:new(L['Items'], addon.mainPanel);
local rarityBox = panel:addCheckBox(L['show items based on rarity']);
local raritySlider = panel:addSlider(0, 8, L['minimum rarity'], '', '', 1);
local reagentsBox = panel:addCheckBox(L['always show reagents']);
local questBox = panel:addCheckBox(L['always show quest items']);
local recipeBox = panel:addCheckBox(L['always show recipes']);
local specialBox = panel:addCheckBox(L['always show focused items']);
local focusBox = panel:addCheckBox(L['only show focused items']);
panel:addLabel(L['focused item ids:']);
local focusIdBox = panel:addEditBox(150, 240);

local saved = addon.SavedVariablesHandler(addonName, 'farmerOptions', {
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
}).vars;

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

raritySlider:OnChange(function (self, value)
  displayRarity(self.edit, value);
end);

panel:OnLoad(function ()
  local options = saved.farmerOptions;

  rarityBox:SetValue(options.rarity);
  raritySlider:SetValue(options.minimumRarity);
  reagentsBox:SetValue(options.reagents);
  questBox:SetValue(options.questItems);
  recipeBox:SetValue(options.recipes);
  specialBox:SetValue(options.special);
  focusBox:SetValue(options.focus);
  focusIdBox:SetText(stringifyItemIds(options.focusItems));
end);

panel:OnSave(function ()
  local options = saved.farmerOptions;

  options.rarity = rarityBox:GetValue();
  options.minimumRarity = raritySlider:GetValue();
  options.reagents = reagentsBox:GetValue();
  options.questItems = questBox:GetValue();
  options.recipes = recipeBox:GetValue();
  options.special = specialBox:GetValue();
  options.focus = focusBox:GetValue();
  options.focusItems = parseItemIds(focusIdBox:GetText());
end);
