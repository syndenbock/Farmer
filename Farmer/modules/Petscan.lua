local addonName, addon = ...

local PJ = C_PetJournal;

local petQueue = {};

local function processPetQueue ()
  if #petQueue == 0 then return end

  -- C_Timer.After(0, function ()
  --   local petId = petQueue[1];

  --   table.remove(petQueue, 1);
  --   PJ.CagePetByID(petId);
  -- end);

  local count = min(#petQueue, 1);

  C_Timer.After(0.4, processPetQueue);

  for i = 1, count, 1 do
    PJ.CagePetByID(petQueue[1]);
    table.remove(petQueue, 1);
  end
end

-- addon:on('BAG_UPDATE_DELAYED', processPetQueue);

local function scanPets ()
  PJ.ClearSearchFilter();

  local petMap = {};
  local _, ownedPets = PJ.GetNumPets();

  petQueue = {};

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
            table.insert(petQueue, info[1]);
          end
        end
      end
    end
  end

  processPetQueue();
end


addon:slash('cagepets', scanPets);
