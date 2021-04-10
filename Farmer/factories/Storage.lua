local _, addon = ...;

local Storage = {};

addon.share('Factory').Storage = Storage;

Storage.__index = Storage;

function Storage:new ()
  local this = {};

  setmetatable(this, Storage);

  this.items = {};
  this.changes = {};

  return this;
end

function Storage:clear ()
  self.items = {};
  self.changes = {};
end

function Storage:clearChanges ()
  self.changes = {};
end

function Storage:getChanges ()
  return self.changes;
end

function Storage:setSlot (slot, id, link, count)
  self:applySlotChange(slot, id, link, count);
  self.items[slot] = {
    id = id,
    count = count,
    link = link,
  };
end

function Storage:applySlotChange (slot, id, link, count)
  local previousContent = self.items[slot];

  if (previousContent == nil) then
    self:addChange(id, link, count);
    return;
  end

  if (previousContent.id ~= id) then
    self:addChange(previousContent.id, previousContent.link,
        -previousContent.count);
    self:addChange(id, link, count);
    return;
  end

  if (previousContent.count ~= count) then
    self:addChange(id, link, count - previousContent.count);
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
  local changes = self.changes[link];

  if (changes == nil) then
    self.changes[link] = {
      id = id,
      count = count,
      link = link,
    };
    return;
  end

  local newCount = changes.count + count;

  if (newCount == 0) then
    self.changes[link] = nil;
  else
    changes.count = changes.count + count;
  end
end
