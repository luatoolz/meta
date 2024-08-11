require "compat53"
require "meta.math"
require "meta.boolean"
require "meta.string"
require "meta.table"
local is = {callable = function(o) return (type(o)=='function' or (type(o)=='table' and type((getmetatable(o) or {}).__call) == 'function')) end}
local index, settings, data, mt

-- auto create and use index
index = setmetatable({}, {
  __mode='v',
--  __gc=function(self)
--    settings[self]=nil
--    data[self]=nil
--  end,
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

mt = {
	__add = function(self, k) if type(k)=='nil' then return self end
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
    local o = select(1, ...)
    if type(o)=='nil' then return nil end

    local len = select('#', ...)
    local new = settings[self].new
    local normalize = settings[self].normalize
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
--        if key~=o then data[self][o]=o end
      end
    else
      data[self][key]=o
--      if key~=o then data[self][o]=o end
    end
    return data[self][key]
  end,
  __index = function(self, k)
    if type(k)=='nil' then return nil end
    local normalize = settings[self].normalize
    local new = settings[self].new
    local key = (normalize and type(k) == 'string') and normalize(k) or k
    return data[self][key] or ((type(k)~='table' and new) and self(k) or nil)
  end,
  __len = function(self) return tonumber(self) end,
  __mod = table.filter,
  __mul = table.map,
  __newindex = function(self, k, v)
    if type(k)=='nil' then return end
		local ordered = settings[self].ordered
    local normalize = settings[self].normalize
    local key = (normalize and type(k) == 'string') and normalize(k) or k
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
  __pow = function(self, t) if is.callable(t) then settings[self].new=t end; return t end,
  __sub   = function(self, it) rawset(self, it, nil); self[it]=nil; return self end,
  __tonumber = function(self)
    local ordered = settings[self].ordered
    if ordered then return #data[self] end
    local i=0; for it,_ in pairs(data[self]) do if type(it)~='number' then i=i+1 end end return i end,
  __tostring = function(self) local inspect = require "inspect"; return inspect(data[self]) or '' end,
  __unm = function(self) data[self] = {}; return nil end,
}

local cmds = {normalize = true, new = true, rawnew = true, refresh = true, existing = true, ordered = true}
return setmetatable({}, {
  __call = function(self, name, normalize, new, rawnew)
    assert(type(name) == 'string')
    local cc = index[name]
    if is.callable(normalize) then settings[name].normalize=normalize end
    if is.callable(new) then settings[name].new=new end
    if rawnew then settings[name].rawnew=rawnew end
    return cc
  end,
  __index = function(self, cmd)
    if cmds[cmd] then
      return setmetatable({}, {
        __index = function(_, k)
          assert(index[k] == index[index[k]])
          assert(settings[k] == settings[index[k]])
          assert(data[k] == data[index[k]])
          if cmd == 'refresh' then data[k] = {} end
          if cmd == 'existing' then
            local normalize = settings[k].normalize
            return function(id) return data[k][(normalize and type(id)=='string') and normalize(id) or id] end
          end
					if cmd == 'ordered' then
						settings[k].ordered=true
						return index[k]
					end
          return settings[k][cmd]
        end,
        __newindex = function(_, k, value)
          assert(index[k] == index[index[k]])
          assert(settings[k] == settings[index[k]])
          assert(data[k] == data[index[k]])
          if cmd=='refresh' then data[k]={} else settings[k][cmd]=value end end,})
    end
    assert(type(cmd)=='string')
    return index[cmd]
  end,
  __newindex = function(self, k, v)
    assert(index[k] == index[index[k]])
    assert(settings[k] == settings[index[k]])
    assert(data[k] == data[index[k]])
    data[k] = {}
  end,
  __tostring = function(self)
    local inspect = require "inspect"
    return inspect(data)
  end,
})
