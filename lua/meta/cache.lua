require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.boolean"
require "meta.string"
require "meta.table"

local is = {
  callable = function(o) return type(o)=='function' or (type(o)=='table' and type((getmetatable(o) or {}).__call) == 'function') end,
  boolean  = function(o) return type(o)=='boolean' end,
  table    = function(o) return type(o)=='table' and not getmetatable(o) end,
  falsy    = function() return false end,
}
local index, settings, data, mt

-- auto create and use index
index = setmetatable({}, {
  __mode='v',
  __index=function(self, t)
    if type(t)=='string' and not rawget(self, t) then
      local cc = setmetatable({}, mt)
      rawset(self, cc, cc)
      rawset(self, t, cc)
    end
    return rawget(self, t)
  end,
})
-- auto use index
settings = setmetatable({}, {
  __mode='k',
  __newindex=function(self, t, v)
    if type(v)~='nil' and type(t)~='table' then t=index[t] end
    rawset(self, t, v)
  end,
  __index=function(self, t)
    t=index[t]
    if not rawget(self, t) then self[t]={} end
    return rawget(self, t)
  end,
})
data = setmetatable({}, getmetatable(settings))

--[[ settings
  new()         -- callable -- if not defined, CACHE DOES NOT CREATE NEW OBJECTS
  normalize()   -- callable -- normalizes cache keys
  rawnew        -- boolean  -- call plain new(...) or new(normalize(...))
	ordered				-- boolean	-- track order (auto create+track integer key for new item) -- for __iter/__pairs/__ipairs
  objnormalize  -- callable -- if defined, called for object arguments (keys only)
  try           -- callable -- generate arguments list for __index action

  get           -- callable -- called instead of standard __index
  put           -- callable -- called instead of standard __newindex
  call          -- callable -- called instead of standard __call

-- call format (new() is undef)
  __call(item, ...) -- registers new item with all keys from list, return new item by default
  index[...]        -- test key and return value, NO OBJECT AUTO CREATED WITHOUT new()

-- call format (new() is defined) -- AUTO CREATE CACHE OBJECTS
  index[...]        -- creates object using key + new()

-- call format to define new cache
  call(name, normalize, new, rawnew) -- return callable+indexable cache index table

-- features
  object is always indexed by itself
  how to add cache keys for object??? -- callback?
  to remove cache object??? gracefully - with removing all cache keys
--]]

--[[ object interface:
  cache.x + ...      -- add item/items to cache.x           cache.x + 'name'                    OR cache.x + {...}
  cache.x(...)       -- execute call handler OR add items   cache.x(arg1, arg2, ...)            OR cache.x(value, key1, key2, ...)
  cache.x .. {...}   -- add items to cache.x                cache.x .. {arg1, arg2, arg3, ...}  OR cache.x .. {k1=v1, k2=v2, ...}
  cache.x[...]       -- get items from cache                cache.x.name                        OR cache.x[{key1, key2, key3, ...}]
  cache.x[...]=v     -- add new key/value item              cache.x.key=value                   OR
  cache.x - ...      -- remove keys from cache.x            cache.x - 'name'                    OR cache.x - {key1, key2, key3, ...}

  iter(cache.x)      -- iterate cache.x keys
  pairs(cache)       -- iterate cache.x pairs

  cache.x ^ {...}    -- set cache.x settings                cache.x ^ {get=..., put=...}        OR
  cache.x % {...}    -- select cache.x items [unchanged]    cache.x % is.loader == table({ name=meta.loader items })
  cache.x * {...}    -- map cache.x items    [transform]    cache.x * is.loader == table({ name=bool pairs })

  -cache.x           -- drop cache.x data and settings
--]]
mt = {
	__add = function(self, k) if type(k)=='nil' then return self end
    local put = settings[self].put
    if put then put(data[self], nil, k); return self end
		local ordered = settings[self].ordered
    local new = settings[self].new
    local normalize = settings[self].normalize
    local rawnew = settings[self].rawnew
		if ordered then self[k]=true
    else
      if new then
        if normalize and not rawnew then
          self[k]=new(normalize(k))
        else
          self[k]=new(k)
        end
      else
        self[k]=true
      end
		end
		return self
	end,
	__concat = function(self, t)
    if type(t)=='function' then for it in t do local _ = self + it end end
		if type(t)=='table' then
      if t[1] then
        for _,v in pairs(t) do local _ = self + v end
      else
        for k,v in pairs(t) do self[k]=v end
      end
    end
		return self
	end,	-- auto add bulk keys
	__iter = function(self)
    local ordered = settings[self].ordered
		return ordered and table.ivalues(data[self]) or table.keys(data[self])
	end,		-- iter ordered
  __call = function(self, ...)
    assert(self)
    local call = settings[self].call
    if call then return call(data[self], ...) end
    local len = select('#', ...)
    local o = len>0 and select(1, ...) or nil
    if type(o)=='nil' then return nil end
    local new = settings[self].new
    local normalize = settings[self].normalize
    local objnormalize = settings[self].objnormalize
    local rawnew = settings[self].rawnew

    local key = (normalize and type(o)~='table') and normalize(...) or o
    if len==1 and data[self][key] then return data[self][key] end

    if (type(o)=='table' and not data[self][o]) or (type(o)~='table' and data[self][o] and not new) or (type(o)~='table' and not data[self][o] and not new and len>1) then
      if type(o)~='table' and data[self][o] then o=data[self][o] end
      for i=1,len do
        local it = select(i, ...)
        if it then
          data[self][it]=o
          local n = (normalize and type(it)=='string') and normalize(it) or nil
          if n then data[self][n]=o end
          if type(it)=='table' and objnormalize then
            n=objnormalize(it)
            if n then data[self][n]=o end
          end
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
      end
    else
      data[self][key]=o
    end
    return data[self][key]
  end,
  __index = function(self, k)
    local get = settings[self].get
    if get then return get(data[self], k) end
    if type(k)=='nil' then return nil end

    local normalize = settings[self].normalize
    local objnormalize = settings[self].objnormalize
    local new = settings[self].new
    local try = settings[self].try
    local key = (normalize and type(k) == 'string') and normalize(k) or k
    if type(k)=='table' and objnormalize and not new then
      key=objnormalize(k)
    end
    if try then
      local rv
      for it in table.tuple(try(k)) do
        rv = data[self][it]
        if rv then return rv end
      end
    end
    return data[self][key] or ((type(k)~='table' and new) and self(k) or nil)
  end,
  __len = function(self) return tonumber(self) end,
  __mod = table.filter,
  __mul = table.map,
  __newindex = function(self, k, v)
    if type(k)=='nil' then
      if type(v)=='nil' then return end
      return self + v
    end
    local put = settings[self].put
    if put then return put(data[self], k, v) end

		local ordered = settings[self].ordered
    local normalize = settings[self].normalize
    local objnormalize = settings[self].objnormalize
    local key = (normalize and type(k) == 'string') and normalize(k) or k
    if type(k)=='table' and objnormalize then
      key=objnormalize(k)
    end
		if ordered then -- default value == true
			if type(v)=='nil' then -- delete key
        data[self][key]=nil
        table.delete(data[self], table.findvalue(data[self], key))
        if k~=key then
          data[self][k]=nil
          table.delete(data[self], table.findvalue(data[self], k))
        end
			else
				if not data[self][key] then
					data[self][key]=true
          table.append_unique(data[self], key)
				end
			end
		else
      if type(v)=='nil' then
        data[self][key]=nil
        if k~=key then data[self][k]=nil end
      else
        data[self][key]=v
      end
    end
  end,
  __pairs = function(self) if settings[self].ordered then return ipairs(data[self]) end; return pairs(data[self]) end,
  __pow = function(self, it) if is.callable(it) then settings[self].new=it end; return it end,
  __preserve=false,
  __sub   = function(self, it) self[it]=nil; return self end, -- todo: ordered
  __tonumber = function(self)
    local ordered = settings[self].ordered
    if ordered then return #data[self] end
    local i=0; for it,_ in pairs(data[self]) do if type(it)~='number' then i=i+1 end end return i end,
  __tostring = function(self) local inspect = require "inspect"; return inspect(data[self]) or '' end,
  __unm = function(self) data[self] = {}; settings[self] = {}; return self end,
}

local cmds = {
  refresh = true,
  existing = true,
  ordered = true,
}
local options = {
  rawnew       = is.boolean,
  ordered      = is.boolean,
  objnormalize = is.callable,
  normalize    = is.callable,
  try          = is.callable,
  new          = is.callable,
  get          = is.callable,
  put          = is.callable,
  call         = is.callable,
}

--[[
  cache(name, ...)   -- create cache with options
  cache.option.x     -- get option value for cache.x
  cache.x = {...}    -- add new values == cache.x .. {...}
  cache[{...}]       -- select multi cache items by key list
  pairs(cache)       -- iterate existing caches
  cache - x          -- drop cache.x
  -cache             -- drop all caches
--]]
return setmetatable({}, {
  __call = function(self, name, ...)
    assert(type(name) == 'string')
    local cc = index[name]
    if select('#', ...)>0 then
      local args = {...}
      if type(args[1])=='table' and not getmetatable(args[1]) then
        args = args[1]
      else
        args = {normalize=args[1], new=args[2], rawnew=args[3]}
      end
      for k,v in pairs(args) do
        if (options[k] or is.falsy)(v) then settings[name][k]=v end
      end
    end
    return cc
  end,
  __index = function(self, cmd)
    if cmds[cmd] or options[cmd] then
      return setmetatable({}, {
        __index = function(_, k)
          assert(index[k] == index[index[k]])
          assert(settings[k] == settings[index[k]])
          assert(data[k] == data[index[k]])
          if not cmds[cmd] then return settings[k][cmd] end
          if cmd == 'existing' then
            local normalize = settings[k].normalize
            return function(id) return data[k][(normalize and type(id)=='string') and normalize(id) or id] end
          end
          if cmd == 'refresh' then data[k] = {} end
          if cmd == 'ordered' then settings[k].ordered=true end
          return index[k]
        end,
        __newindex = function(_, k, value)
          assert(index[k] == index[index[k]])
          assert(settings[k] == settings[index[k]])
          assert(data[k] == data[index[k]])
          if cmd=='refresh' then data[k]={} else settings[k][cmd]=value end end,})
    end
    assert(type(cmd)=='string' or type(cmd)=='table')
    return index[cmd]
  end,
  __newindex = function(self, it, opt)
    assert(index[it] == index[index[it]])
    assert(settings[it] == settings[index[it]])
    assert(data[it] == data[index[it]])
    data[it] = {}
    if is.table(opt) then
      for k,v in pairs(opt) do
        if (options[k] or is.falsy)(v) then settings[it][k]=v end
      end
    end
  end,
  __tostring = function(self)
    local inspect = require "inspect"
    return inspect(data)
  end,
})