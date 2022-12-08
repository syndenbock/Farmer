local _, addon = ...

if (_G.C_PetJournal == nil) then return end

local C_Container = addon.import('polyfills/C_Container');

local tinsert = _G.tinsert;
local tremove = _G.tremove;
local C_Timer = _G.C_Timer;
local PetJournal = _G.C_PetJournal;
local CagePetByID = PetJournal.CagePetByID;
local GetPetInfoByIndex = PetJournal.GetPetInfoByIndex;
local ClearSearchFilter = PetJournal.ClearSearchFilter;
local GetNumPets = PetJournal.GetNumPets;
local GetContainerNumFreeSlots = C_Container.GetContainerNumFreeSlots;
local NUM_BAG_SLOTS = _G.NUM_BAG_SLOTS;

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

local function processPetQueue (petQueue, freeSlots)
  CagePetByID(petQueue[1]);
  tremove(petQueue, 1);
  freeSlots = freeSlots - 1;

  --[[ we want to process queue once with no slots left, so the game displays
       an "inventory is full" message once --]]
  if (freeSlots >= 0 and #petQueue > 0) then
    C_Timer.After(0.4, function ()
      processPetQueue(petQueue, freeSlots);
    end);
  end
end

local function checkPetById (petMap, petQueue, petId, petInfo)
  local minCount = 2;

  if (petMap[petId] <= minCount) then return end

  local isFavorite = petInfo[6];

  if (isFavorite) then
    local petName = petInfo[8];

    addon.printAddonMessage(petName .. ' is owned 3 times, but favorited');
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

local function scanPets ()
  local freeSlots = getInventoryFreeSlots();

  if (freeSlots == 0) then return end;

  --[[ Filters have to be cleared because PetJournal functions can only access
       pets that are currently displayed ]]
  ClearSearchFilter();

  local _, ownedPets = GetNumPets();
  local petMap = {};
  local petQueue = {};

  for x = 1, ownedPets, 1 do
    readPetByIndex(petMap, petQueue, x);
  end

  if (#petQueue > 0) then
    processPetQueue(petQueue, freeSlots);
  else
    print('no pets to be caged!')
  end
end

addon.slash('cagepets', scanPets);
