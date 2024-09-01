local _, addon = ...;

local CreateFromMixins = _G.CreateFromMixins;
local wipe = _G.wipe;

local Storage = addon.export('Class/Storage', {});

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
  local content = self.items[slot];

  if (content == nil) then
    self:__fillSlot(slot, id, link, count);
  elseif (content.link ~= link) then
    self:__updateSlot(content, id, link, count);
  elseif (content.count ~= count) then
    self:__updateCount(content, id, link, count);
  end
end

function Storage:__fillSlot (slot, id, link, count)
  self:addChange(id, link, count);
  self.items[slot] = {
    id = id,
    count = count,
    link = link,
  };
end

function Storage:__updateSlot (content, id, link, count)
  self:__applySlotClearChange(content);
  self:addChange(id, link, count);

  content.id = id;
  content.link = link;
  content.count = count;
end

function Storage:__updateCount (content, id, link, count)
  self:addChange(id, link, count - content.count);
  content.count = count;
end

function Storage:clearSlot (slot)
  if (self.items[slot] ~= nil) then
    self:__applySlotClearChange(self.items[slot]);
    self.items[slot] = nil;
  end
end

function Storage:clearContent ()
  for slot in pairs(self.items) do
    self:clearSlot(slot);
  end
end

function Storage:__applySlotClearChange (content)
  self:addChange(content.id, content.link, -content.count);
end

function Storage:addChange (id, link, count)
  local changes = self.changes[id];

  if (changes == nil) then
    self:__createChange(id, link, count);
  else
    self:__updateChanges(changes, link, count);
  end
end

function Storage:__createChange (id, link, count)
  self.changes[id] = {
    count = count,
    links = {
      [link] = count,
    },
  };
end

function Storage:__updateChanges (changes, link, count)
  changes.count = changes.count + count;
  changes.links[link] = (changes.links[link] or 0) + count;
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
