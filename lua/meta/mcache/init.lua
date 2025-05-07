require "meta.table"
local iter      = require "meta.iter"
local is        = require 'meta.is'
local append    = table.append

local falsy     = function() end
local index, settings, data, mt

local cmds = {
  refresh       = true,
  existing      = true,
  ordered       = true,
  revordered    = true,
  conf          = true,
  getter        = true,
  setter        = true,
  caller        = true,
  adder         = true,
  remover       = true,
}
local options = {
  ordered       = is.boolean,
  rev           = is.boolean,

  normalize     = is.callable,
  objnormalize  = is.callable,
  new           = is.callable,
  rawnew        = is.boolean,
  try           = is.callable,

  get           = is.callable,
  put           = is.callable,
  call          = is.callable,

  mul           = is.callable,
  mod           = is.callable,
  pow           = is.callable,
  div           = is.callable,

  init          = is.callable,
  vars          = is.table,

--[[
  getter        = is.callable,
  setter        = is.callable,
  caller        = is.callable,
  adder         = is.callable,
  remover       = is.callable,
--]]
}

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

local function initialize(self)
  if not self then return nil end
  local opt = settings[self]
  local init, name = opt.init, opt.name
  _ = name
  if init then
    opt.init=nil;
    if is.func(init) then
      return self .. init(data[self])
    end
    if is.table(init) then
      return self .. init
    end
  end
end

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

  div           -- callable -- __div -- first/action
  mul           -- callable -- __mul -- map
  mod           -- callable -- __mod -- filter
  pow           -- callable -- __pow -- config/bind/link/assign   NOT ASSIGNABLE

  init          -- callable/table   -- initial data; returns true/false/nil or nil+error; if table or function - concatenated
  vars          -- table    -- legit var names, optionally typed

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
  __preserve=false,
	__add = function(self, k) if type(k)=='nil' then return self end
    initialize(self)
    local opt = settings[self]
    local put, ordered, new, normalize, rawnew =
      opt.put, opt.ordered, opt.new, opt.normalize, opt.rawnew

    if put then put(data[self], nil, k); return self end
		if ordered then self[k]=true else
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
	__concat = function(self, x)
    initialize(self)
    if x then
      for v,k in iter(x) do
        if type(k)=='number' or type(k)=='nil' then
          append(self, v)
        else
          append(self, v, k)
        end
      end
    end
		return self
	end,	-- auto add bulk keys
	__iter = function(self)
    initialize(self)
    local ordered = settings[self].ordered
		return ordered and iter.ivalues(self) or iter.values(data[self])
	end,		-- iter ordered
  __call = function(self, ...)
    assert(self)
    initialize(self)

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
          if (not rawequal(it, o)) or len>1 then
            data[self][it]=o
          end
          local n = (normalize and type(it)=='string') and normalize(it) or nil
          if n then data[self][n]=o end
          if type(it)=='table' and objnormalize then
            n=objnormalize(it)
            if n then data[self][n]=o end
          end
        end
      end
      return data[self][o]
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
    initialize(self)
    local get = settings[self].get
    if get then return get(data[self], k) end
    if type(k)=='nil' then return nil end

    local normalize = settings[self].normalize
    local objnormalize = settings[self].objnormalize
    local new = settings[self].new
    local try = settings[self].try
    local vars = settings[self].vars
    local ordered = settings[self].ordered
    local rev = settings[self].rev

    local key = (normalize and type(k) == 'string') and normalize(k) or k
    if vars then if vars[key] then return data[self][key] end; return end
    if type(k)=='table' and objnormalize and not new then
      key=objnormalize(k)
    end

    local rv
    if try then
      for it in iter.tuple(try(k)) do
        rv = data[self][it]
        if rv then return rv end
      end
    end
    if ordered and type(k)=='number' then
      if rev then
        local len=#data[self]
        if k>=1 and k<=len then return data[self][(len+1)-k] end
      else return data[self][k] end
    end
    rv=data[self][key]
    if type(rv)~='nil' then return rv end
    return ((type(k)~='table' and new) and self(k) or nil)
  end,
--  __len = function(self) return tonumber(self) end,
  __div = function(self, to) return (settings[self].div or table.div)(self, to) end,
  __mul = function(self, to) return (settings[self].mul or table.map)(self, to) end,
  __mod = function(self, to) return (settings[self].mod or table.filter)(self, to) end,
  __name='mcache.item',
  __newindex = function(self, k, v)
    initialize(self)
    if type(k)=='nil' then
      if type(v)=='nil' then return end
      if type(v)=='table' then return self .. v end
      return self + v
    end
    local put = settings[self].put
    if put then return put(data[self], k, v) end

		local ordered = settings[self].ordered
    local normalize = settings[self].normalize
    local objnormalize = settings[self].objnormalize
    local vars = settings[self].vars

    local key = (normalize and type(k) == 'string') and normalize(k) or k
    if vars and type(key)=='string' then
      if type(v)=='nil' then data[self][key]=v else
        if vars[key] and vars[key](v) then
          data[self][key]=v
        end end
      return
    end

    if type(k)=='table' and objnormalize then
      key=objnormalize(k)
    end
		if ordered then -- default value == true
			if type(v)=='nil' then -- delete key
        data[self][key]=nil
        table.delete(data[self], table.find(data[self], key))
        if k~=key then
          data[self][k]=nil
          table.delete(data[self], table.find(data[self], k))
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
  __pairs = function(self) initialize(self)
    local opt=settings[self]
    if opt.ordered then return ipairs(self) end
--      if opt.rev then return table.irevpairs(data[self]) else return ipairs(data[self]) end
    return pairs(data[self]) end,
  __pow = function(self, it)
    if is.callable(it) then settings[self].new=it; return it end
    if type(it)=='table' and not getmetatable(it) then
      for k,v in pairs(it) do
        if (options[k] or falsy)(v) then settings[self][k]=v end
      end
    end
    return self
  end,
  __sub   = function(self, it) initialize(self); self[it]=nil; return self end, -- todo: ordered
  __tonumber = function(self)
    initialize(self)
    local ordered = settings[self].ordered
    if ordered then return #data[self] end
    local i=0; for it,v in pairs(data[self]) do if type(it)~='number' then i=i+1 end end return i end,
  __tostring = function(self)
    return settings[self].name
  end,
  __unm = function(self) data[self]={}; settings[self]={}; return self end,
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
    settings[name].name = name
    if select('#', ...)>0 then
      local args = {...}
      if type(args[1])=='table' and not getmetatable(args[1]) then
        args = args[1]
      else
        args = {normalize=args[1], new=args[2], rawnew=args[3]}
      end
      for k,v in pairs(args) do
        if (options[k] or falsy)(v) then settings[name][k]=v end
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
          local opt=settings[k]
          opt.name = k
          if not cmds[cmd] then return opt[cmd] end

          if cmd == 'refresh'    then data[k] = {} end
          if cmd == 'ordered'    then opt.ordered=true end
          if cmd == 'revordered' then opt.ordered=true; opt.rev=true; end
          if cmd == 'conf'       then return opt end

          if cmd == 'existing'   then
            local normalize = opt.normalize
            return function(id)
              if not opt.new then return index[k][id] end
              if type(id)=='table' and opt.objnormalize then return data[k][opt.objnormalize(id)] end
              return data[k][(normalize and type(id)=='string') and normalize(id) or id]
            end
          end
          if cmd == 'getter'     then return opt.getter  or table.save(opt, cmd, function(it)  return index[k][it] end) end
          if cmd == 'setter'     then return opt.setter  or table.save(opt, cmd, function(it, v)      index[k][it]=v end) end
          if cmd == 'caller'     then return opt.caller  or table.save(opt, cmd, function(...) return index[k](...) end) end
          if cmd == 'adder'      then return opt.adder   or table.save(opt, cmd, function(it)  return index[k] + it end) end
          if cmd == 'remover'    then return opt.remover or table.save(opt, cmd, function(it)  return index[k] - it end) end

          return index[k]
        end,
        __name='cache.conf',
        __newindex = function(_, k, value)
          assert(index[k] == index[index[k]])
          assert(settings[k] == settings[index[k]])
          assert(data[k] == data[index[k]])
          if cmd=='conf' then
            if type(value)=='table' then
              for n,v in pairs(value) do settings[k][n]=v end
              data[k]={}
            end
          elseif cmd=='refresh' then data[k]={} else settings[k][cmd]=value end end,})
    end
    assert(type(cmd)=='string' or type(cmd)=='table')
    if type(cmd)=='string' and not settings[cmd].name then settings[cmd].name=cmd end
    return index[cmd]
  end,
  __name='mcache',
  __newindex = function(self, it, values)
    assert(index[it] == index[index[it]])
    assert(settings[it] == settings[index[it]])
    assert(data[it] == data[index[it]])
    if type(values)=='table' then return self[it] .. values end
    if type(values)=='nil' then return -self[it] end
  end,
  __pairs = function(self) return pairs(index) end,
  __tonumber = function(self)
    local i=0; for it,_ in pairs(index) do if type(it)=='string' then i=i+1 end end return i end,
  __tostring = function(self)
    local inspect = require "inspect"
    return inspect(data)
  end,
  __unm = function(self)
    for k in pairs(self) do
      if type(k)=='table' then assert(-k) end
    end
    return self
  end,
})