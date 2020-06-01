local addonName, addon = ...

local UNITID_PLAYER = 'player';
local PJ = C_PetJournal;

local function GetFreeBagSlots ()
  local freeSlots = 0;

  for i = 1, NUM_BAG_SLOTS, 1 do
    local index = ContainerIDToInventoryID(i);
    local link = GetInventoryItemLink(UNITID_PLAYER, index);

    local info = {GetItemInfoInstant(link)};
    local subclassId = info[7];
    local standardContainerSubclass = 0;

    if (subclassId == standardContainerSubclass) then
      freeSlots = freeSlots + GetContainerNumFreeSlots(i);
    end
  end

  return freeSlots;
end

local function processPetQueue (petQueue, freeSlots)
  PJ.CagePetByID(petQueue[1]);
  table.remove(petQueue, 1);

  --[[ we want to process queue once with no slots left, so the game displays
       an "inventory is full" message once --]]
  if (freeSlots > 0 and #petQueue > 0) then
    C_Timer.After(0.4, function ()
      processPetQueue(petQueue, freeSlots - 1);
    end);
  end
end

-- addon:on('BAG_UPDATE_DELAYED', processPetQueue);

local function scanPets ()
  PJ.ClearSearchFilter();

  local _, ownedPets = PJ.GetNumPets();
  local petMap = {};
  local petQueue = {};

  for i = 1, ownedPets, 1 do
    local info = {PJ.GetPetInfoByIndex(i)};

    if (info[16] == true) then
      local petId = info[11];

      if (petMap[petId] == nil) then
        petMap[petId] = 1;
      else
        petMap[petId] = petMap[petId] + 1;

        if (petMap[petId] == 3) then
          if (info[6] == true) then
            print(info[8] .. ' is owned 3 times, but favorited');
          else
            petQueue[#petQueue + 1] = info[1];
          end
        end
      end
    end
  end

  processPetQueue(petQueue, GetFreeBagSlots());
end

addon:slash('cagepets', scanPets);
