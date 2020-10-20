local _, addon = ...;

if (addon.isClassic()) then return end

local Storage = addon.Factory.Storage;
local Items = addon.Items;

local GetCurrentGuildBankTab = _G.GetCurrentGuildBankTab;
local GetGuildBankItemInfo = _G.GetGuildBankItemInfo;
local GetGuildBankItemLink = _G.GetGuildBankItemLink;
local GetItemInfoInstant = _G.GetItemInfoInstant;

local storage;
local currentTab;
local isOpen = false;

local function readGuildBankSlot (tabContent, tabIndex, slotIndex)
  local link = GetGuildBankItemLink(tabIndex, slotIndex);

  if (not link) then return end

  local id = GetItemInfoInstant(link);
  local info = {GetGuildBankItemInfo(tabIndex, slotIndex)};
  local count = info[2];

  tabContent:addItem(id, link, count);
end

local function readGuildBankTab (tabIndex)
  --[[ This variable only becomes available after the guild bank has been
       opened. If the guild bank frame is replaced by an addon, it will stay
       unavailable and we use the hardcoded value from Blizzard's code.
       Again, I have no clue why they did not put a global constant in the code
       for this.]]
  local MAX_GUILDBANK_SLOTS_PER_TAB = _G.MAX_GUILDBANK_SLOTS_PER_TAB or 98;
  local tabContent = Storage:new();

  for slotIndex = 1, MAX_GUILDBANK_SLOTS_PER_TAB, 1 do
    readGuildBankSlot(tabContent, tabIndex, slotIndex);
  end

  return tabContent;
end

local function readCurrentTab ()
  local tabIndex = GetCurrentGuildBankTab();

  storage = readGuildBankTab(tabIndex);

  return tabIndex;
end

addon.on('GUILDBANKFRAME_OPENED', function ()
  isOpen = true;
  currentTab = readCurrentTab();
  Items.updateCurrentInventory();
end);

addon.on('GUILDBANKBAGSLOTS_CHANGED', function ()
  if (isOpen == false) then return end

  local tabIndex = readCurrentTab();

  --[[ Guild bank content was not updated, but tab was switched. ]]
  if (tabIndex ~= currentTab) then
    currentTab = tabIndex;
    Items.updateCurrentInventory();
  end
end);

addon.on({'GUILDBANKFRAME_CLOSED', 'PLAYER_ENTERING_WORLD'}, function ()
  isOpen = false;
  storage = nil;
  currentTab = nil;
end);

Items.addStorage(function ()
  return {storage};
end);
