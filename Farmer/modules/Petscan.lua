local _, addon = ...

if (_G.C_PetJournal == nil) then return end

local SlashCommands = addon.import('core/logic/SlashCommands');
local Strings = addon.import('core/utils/Strings');
local C_Container = addon.import('client/polyfills/C_Container');

local tinsert = _G.tinsert;
local C_Timer = _G.C_Timer;
local PetJournal = _G.C_PetJournal;
local CagePetByID = PetJournal.CagePetByID;
local GetPetInfoByIndex = PetJournal.GetPetInfoByIndex;
local ClearSearchFilter = PetJournal.ClearSearchFilter;
local GetNumPets = PetJournal.GetNumPets;
local GetContainerNumFreeSlots = C_Container.GetContainerNumFreeSlots;
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS;

local routine = nil;

local function getBagFreeSlots (bagIndex)
  local generalBagType = 0;
  local freeSlots, bagType = GetContainerNumFreeSlots(bagIndex);

  return bagType == generalBagType and freeSlots or 0;
end

local function getInventoryFreeSlots ()
  local freeSlots = 0;

  for x = 1, NUM_BAG_SLOTS, 1 do
    freeSlots = freeSlots + getBagFreeSlots(x);
  end

  return freeSlots;
end

local function checkPetById (petMap, petQueue, petId, petInfo)
  local minCount = 2;

  if (petMap[petId] <= minCount) then return end

  local isFavorite = petInfo[6];

  if (isFavorite) then
    local petName = petInfo[8];

    Strings.printAddonMessage(petName .. ' is owned 3 times, but favorited');
    return;
  end

  local identifier = petInfo[1];

  tinsert(petQueue, identifier);
end

local function readPetByIndex (petMap, petQueue, petIndex)
  local petInfo = {GetPetInfoByIndex(petIndex)};
  local isTradeable = petInfo[16];

  if (not isTradeable) then return end

  local petId = petInfo[11];

  petMap[petId] = (petMap[petId] or 0) + 1;
  checkPetById(petMap, petQueue, petId, petInfo);
end

local function determineExcessPets ()
  --[[ Filters have to be cleared because PetJournal functions can only access
       pets that are currently displayed ]]
  ClearSearchFilter();

  local petMap = {};
  local petQueue = {};
  local _, ownedPets = GetNumPets();

  for x = 1, ownedPets, 1 do
    readPetByIndex(petMap, petQueue, x);
  end

  return petQueue;
end

local function cageExcessPets ()
  local petQueue = determineExcessPets();
  local freeSlots = getInventoryFreeSlots();
  local currentIndex = 1;

  --[[ we want to process queue once with no slots left, so the game displays
        an "inventory is full" message once --]]
  for _, petId in ipairs(petQueue) do
    if (freeSlots <= 0) then
      break;
    end

    CagePetByID(petId);
    freeSlots = freeSlots - 1;
    coroutine.yield();
  end
end

local function executeCoroutine ()
  if (coroutine.resume(routine)) then
    C_Timer.After(0.5, executeCoroutine);
  else
    routine = nil;
  end
end

SlashCommands.addCommand('cagepets', function ()
  if (routine ~= nil) then
    return;
  end

  routine = coroutine.create(cageExcessPets);
  executeCoroutine();
end);
