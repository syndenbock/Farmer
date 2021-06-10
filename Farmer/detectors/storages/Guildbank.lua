local _, addon = ...;

if (_G.GetGuildBankItemInfo == nil) then return end

local Items = addon.Items;

local GetCurrentGuildBankTab = _G.GetCurrentGuildBankTab;
local GetGuildBankItemInfo = _G.GetGuildBankItemInfo;
local GetGuildBankItemLink = _G.GetGuildBankItemLink;
local GetItemInfoInstant = _G.GetItemInfoInstant;

local storage = addon.Factory.Storage:new();
local currentTab;
local isOpen = false;

local function readGuildBankSlot (tabContent, tabIndex, slotIndex)
  local link = GetGuildBankItemLink(tabIndex, slotIndex);

  if (not link) then
    tabContent:clearSlot(slotIndex);
    return;
  end

  local id = GetItemInfoInstant(link);
  local info = {GetGuildBankItemInfo(tabIndex, slotIndex)};
  local count = info[2];

  tabContent:setSlot(slotIndex, id, link, count);
end

local function readGuildBankTab (tabIndex)
  --[[ This variable only becomes available after the guild bank has been
       opened. If the guild bank frame is replaced by an addon, it will stay
       unavailable and we use the hardcoded value from Blizzard's code.
       Again, I have no clue why they did not put a global constant in the code
       for this.]]
  local MAX_GUILDBANK_SLOTS_PER_TAB = _G.MAX_GUILDBANK_SLOTS_PER_TAB or 98;

  for slotIndex = 1, MAX_GUILDBANK_SLOTS_PER_TAB, 1 do
    readGuildBankSlot(storage, tabIndex, slotIndex);
  end

  return storage;
end

local function readCurrentGuildBankTab ()
  local index = GetCurrentGuildBankTab();

  readGuildBankTab(index);

  return index;
end

addon.on('GUILDBANKFRAME_OPENED', function ()
  isOpen = true;
end);

addon.on('GUILDBANKBAGSLOTS_CHANGED', function ()
  if (isOpen == false) then return end

  local tabIndex = readCurrentGuildBankTab();

  --[[ Guild bank content was not updated, but tab was switched.
    This includes handling the guild bank getting opened ]]
  if (tabIndex ~= currentTab) then
    storage:clearChanges();
    currentTab = tabIndex;
  end
end);

addon.on({'GUILDBANKFRAME_CLOSED', 'PLAYER_ENTERING_WORLD'}, function ()
  isOpen = false;
  storage:clear();
  currentTab = nil;
end);

Items.addStorage({storage});
