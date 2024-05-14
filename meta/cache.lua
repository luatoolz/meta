require "compat53"

local index = {}
local settings = {}
local data = {}

--[[ settings
  new() - function/callable table -- if not defined, CACHE DOES NOT CREATE NEW OBJECTS
  normalize() -- function/callable -- normalizes cache keys

-- call format (new() is undef)
  __call(item, ...) -- registers new item with all keys from list, return new item by default
  index[...]        -- test key and return value, NO OBJECT IS CREATED WITHOUT new()

-- call format (new() is defined) -- CACHE CREATE OBJECTS
  index[...] -- creates object using key

-- call format to define new cache
  call(name, normalize) -- return callable+indexable cache index table

-- features
  object is always indexed by itself
  how to add cache keys for object??? -- callback?
  to remove cache object??? gracefully - with removing all cache keys
  
--]]

local noop = function(...) return ... end

-- define without new()
local mt2 = {
  __index = function(self, k)
    local normalize = settings[self].normalize or noop
    return data[self][k] or data[self][normalize(k)]
  end,
  __newindex = function(self, k, v)
    local normalize = settings[self].normalize or noop
    data[self][k] = v
    data[self][normalize(k)] = v
  end,
  __call = function(self, o, ...)
    assert(type(o)~='nil')
    assert(settings[self])
    local normalize = settings[self].normalize or noop
    data[self][o] = o
    for i=1,select('#', ...) do
      local k = select(i, ...)
      data[self][k] = o
      data[self][normalize(k)] = o
    end
    return o
  end,
}

-- define with new()
local mt = {
  __index = function(self, k)
    local normalize = settings[self].normalize or noop
    local new = settings[self].new
    local rv = data[self][k] or data[self][normalize(k)]
    if (not rv) and new then
      rv = self(new(k), k, normalize(k))
    end
    return rv
  end,
  __newindex = function(self, k, v)
    local normalize = settings[self].normalize or noop
    data[self][k] = v
    data[self][normalize(k)] = v
  end,
  __call = function(self, o, ...)
    if type(o)=='nil' then return end
    assert(type(o)~='nil')
    assert(settings[self])
    local normalize = settings[self].normalize or noop
    if type(o)=='string' then
      o = self[o]
      if not o then return end
    end
    if o and type(o)~='string' and (not rawget(data[self], o)) then
      data[self][o] = o
    end
    for i=1,select('#', ...) do
      local k = select(i, ...)
      data[self][k] = o
      data[self][normalize(k)] = o
    end
    return o
  end,
}

return setmetatable({}, {
  __index = function(self, k)
    return index[k]
  end,
  __newindex = function(self, k, v)
    error('__call(name, normalize) to register new cache or __index[name] to get existing')
  end,
  __call = function(self, name, normalize, new)
    assert(type(name)=='string')
    local cc = index[name]
    if not cc then
      cc = setmetatable({}, mt)
      index[cc]=cc
      index[name]=cc
      settings[cc]={}
      data[cc]={}
    end
    if normalize then
      local t = type(normalize)
      assert(t=='function' or (t=='table' and type((getmetatable(normalize) or {}).__call)=='function'))
      settings[cc].normalize = normalize
      assert(settings[cc].normalize)
    end
    if new then
      local t = type(new)
      assert(t=='function' or (t=='table' and type((getmetatable(new) or {}).__call)=='function'))
      settings[cc].new = new
      assert(settings[cc].new)
    end
    return cc
  end,
})
