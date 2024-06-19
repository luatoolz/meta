require "compat53"

local index = {}
local settings = {}
local data = {}

--[[ settings
  new()         -- callable -- if not defined, CACHE DOES NOT CREATE NEW OBJECTS
  normalize()   -- callable -- normalizes cache keys
  rawnew        -- boolean  -- call plain new(...) or new(normalize(...))

-- call format (new() is undef)
  __call(item, ...) -- registers new item with all keys from list, return new item by default
  index[...]        -- test key and return value, NO OBJECT IS CREATED WITHOUT new()

-- call format (new() is defined) -- CACHE CREATE OBJECTS
  index[...] -- creates object using key

-- call format to define new cache
  call(name, normalize, new, rawnew) -- return callable+indexable cache index table

-- features
  object is always indexed by itself
  how to add cache keys for object??? -- callback?
  to remove cache object??? gracefully - with removing all cache keys
--]]

local mt = {
  __pairs = function(self)
    return pairs(data[self] or {})
  end,
  __index = function(self, k)
    if type(k)=='nil' then return nil end
    settings[self] = settings[self] or {}
    data[self] = data[self] or {}

    local normalize = settings[self].normalize
    local new = settings[self].new
    local key = (normalize and type(k) == 'string') and normalize(k) or k
    return data[self][key] or ((type(k)~='table' and new) and self(k) or nil)
  end,
  __unm = function(self)
    data[self] = {};
    return nil
  end,
  __newindex = function(self, k, v)
    settings[self] = settings[self] or {}
    data[self] = data[self] or {}
    local normalize = settings[self].normalize
    if k then
      k = (normalize and type(k) == 'string') and normalize(k) or k
      data[self][k] = v
    end
  end,
  __call = function(self, ...)
    assert(self)
    settings[self] = settings[self] or {}
    data[self] = data[self] or {}
    local o = select(1, ...)
    if type(o)==nil then return nil end

    local len = select('#', ...)
    local new = settings[self].new
    local normalize = settings[self].normalize
    local rawnew = settings[self].rawnew

    local key = (normalize and type(o)~='table') and normalize(...) or o
    if len==1 and data[self][key] then return data[self][key] end

    if (type(o)=='table' and not data[self][o]) or (type(o)~='table' and data[self][o] and not new) then
      if type(o)~='table' then o=data[self][o] end
      for i=1,len do
        local it = select(i, ...)
        if it then
          data[self][it]=o
          local n = (normalize and type(it)=='string') and normalize(it) or nil
          if n then data[self][n]=o end
        end
      end
      return o
    end
    if new and type(o)~='table' then
      if normalize and not rawnew then
        o = new(normalize(...))
      else
        o = new(...)
      end
      if o then
        if normalize then data[self][key]=o end
        if key~=o then data[self][o]=o end
      end
    else
      data[self][key]=o
      if key~=o then data[self][o]=o end
    end
    return data[self][key]
  end,
}
local cmds = {normalize = true, new = true, rawnew = true, refresh = true}
return setmetatable({}, {
  __index = function(self, cmd)
    local this = self
    if cmds[cmd] then
      return setmetatable({}, {
        __index = function(_, k)
          if not index[k] then this(k) end -- create if not exists
          assert(index[k])
          assert(settings[index[k]])
          if cmd == 'refresh' then data[index[k]] = {} end
          return (settings[self[k]] or {})[cmd]
        end,
        __newindex = function(_, k, value)
          if not index[k] then this(k) end -- create if not exists
          if cmd == 'refresh' then
            data[index[k]] = {}
          else
            (settings[index[k]] or {})[cmd] = value
          end
        end,
      })
    end
    return index[cmd] or self(cmd)
  end,
  __newindex = function(self, k, v)
    if not index[k] then self(k) end -- create if not exists
    assert(index[k])
    if index[k] then data[index[k]] = {} end
  end,
  __call = function(self, name, normalize, new, rawnew)
    assert(type(name) == 'string')
    local cc = index[name]
    if not cc then
      cc = setmetatable({}, mt)
      index[cc] = cc
      index[name] = cc
      settings[cc] = {}
      data[cc] = {}
    end
    if normalize then
      local t = type(normalize)
      assert(t == 'function' or (t == 'table' and type((getmetatable(normalize) or {}).__call) == 'function'))
      settings[cc].normalize = normalize
      assert(settings[cc].normalize)
    end
    if new then
      local t = type(new)
      assert(t == 'function' or (t == 'table' and type((getmetatable(new) or {}).__call) == 'function'))
      settings[cc].new = new
      assert(settings[cc].new)
    end
    if rawnew then
      settings[cc].rawnew = rawnew
    end
    return cc
  end,
})
