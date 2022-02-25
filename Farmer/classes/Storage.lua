local _, addon = ...;

local CreateFromMixins = _G.CreateFromMixins;
local wipe = _G.wipe;

local Storage = {};

addon.share('Factory').Storage = Storage;

function Storage:new ()
  local this = CreateFromMixins(Storage);

  this.items = {};
  this.changes = {};

  return this;
end

function Storage:clear ()
  wipe(self.items);
  wipe(self.changes);
end

function Storage:clearChanges ()
  wipe(self.changes);
end

function Storage:getChanges ()
  return self.changes;
end

function Storage:setSlot (slot, id, link, count)
  local previousContent = self.items[slot];

  if (previousContent == nil) then
    self:addChange(id, link, count);
    self.items[slot] = {
      id = id,
      count = count,
      link = link,
    };
  elseif (previousContent.link ~= link) then
    self:addChange(previousContent.id, previousContent.link,
        -previousContent.count);
    self:addChange(id, link, count);

    previousContent.id = id;
    previousContent.link = link;
    previousContent.count = count;
  elseif (previousContent.count ~= count) then
    self:addChange(id, link, count - previousContent.count);
    previousContent.count = count;
  end
end

function Storage:clearSlot (slot)
  self:applySlotClearChange(slot);
  self.items[slot] = nil;
end

function Storage:applySlotClearChange (slot)
  local previousContent = self.items[slot];

  if (previousContent == nil) then
    return;
  end

  self:addChange(previousContent.id, previousContent.link,
      -previousContent.count);
end

function Storage:addChange (id, link, count)
  local changes = self.changes[id];

  if (changes == nil) then
    self.changes[id] = {
      count = count,
      links = {
        [link] = count,
      },
    };
    return;
  end

  local links = changes.links;

  changes.count = changes.count + count;
  links[link] = (links[link] or 0) + count;
end

function Storage:printContents ()
  for slot, info in pairs(self.items) do
    print(slot, info.link, info.count);
  end
end

function Storage:printChanges ()
  for _, info in pairs (self.changes) do
    for link, count in pairs(info.links) do
      print(link, count);
    end
  end
end
