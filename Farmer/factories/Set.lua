local _, addon = ...;

local Factory = addon.share('Factory');

local Set = {};

Factory.Set = Set;

Set.__index = Set;

function Set:new (items)
  local this = {};

  setmetatable(this, Set);

  this.items = {};

  if (items) then
    this:add(items);
  end

  return this;
end

function Set:has (item)
  return (self.items[item] == true);
end

function Set:addItem (item)
  self.items[item] = true;
end

function Set:addItems (items)
  for x = 1, #items, 1 do
    self:addItem(items[x]);
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
  self.items[item] = nil;
end

function Set:removeItems (items)
  for x = 1, #items, 1 do
    self:removeItem(items[x]);
  end
end

function Set:clear ()
  self.items = {};
end

function Set:forEach (callback)
  for item in self.items do
    callback(item);
  end
end

function Set:getItems ()
  return self.items;
end
