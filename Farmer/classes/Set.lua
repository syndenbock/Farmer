local _, addon = ...;

local tinsert = table.insert;

local Set = {};

addon.share('Class').Set = Set;

Set.__index = Set;

function Set:new (items)
  local this = {};

  setmetatable(this, Set);

  this.items = {};
  this.itemCount = 0;

  if (items) then
    this:add(items);
  end

  return this;
end

function Set:getItemCount ()
  return self.itemCount;
end

function Set:has (item)
  return (self.items[item] == true);
end

function Set:addItem (item)
  if (not self:has(item)) then
    self.items[item] = true;
    self.itemCount = self.itemCount + 1;
  end
end

function Set:addItems (items)
  for _, item in ipairs(items) do
    self:addItem(item);
  end
end

function Set:add (items)
  if (type(items) == 'table') then
    self:addItems(items);
  else
    self:addItem(items);
  end
end

function Set:removeItem (item)
  if (self:has(item)) then
    self.items[item] = nil;
    self.itemCount = self.itemCount - 1;
  end
end

function Set:removeItems (items)
  for _, item in ipairs(items) do
    self:removeItem(item);
  end
end

function Set:clear ()
  self.items = {};
  self.itemCount = 0;
end

function Set:forEach (callback)
  for _, item in ipairs(self:getItems()) do
    callback(item);
  end
end

function Set:getItems ()
  local items = {};

  for item in pairs(self.items) do
    tinsert(items, item);
  end

  return items;
end
