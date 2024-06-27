require "compat53"
require 'meta.boolean'
require 'meta.math'
require 'meta.string'
local is = require 'meta.is'

local maxn = rawget(table, 'maxn')

local function return_self(x) return x end
local function return_nil(x) return end
local make_filter = function(fl)
  if type(fl)=='nil' then return function(v, ...) if type(v)~='nil' then return v end end end
  assert(is.callable(fl), 'table:filter make_filter require is.callable')
  return function(v, ...) if type(v)~='nil' and fl(v, ...) then return v end end
  end

local function args(...)
  if select('#', ...)==0 then return {} end
  if select('#', ...)==1 and type(select(1, ...))=='table' then return select(1, ...) end
  return {...}
end

function table.callable(...)
  for i=1,select('#', ...) do
    local self = select(i, ...)
    if (type(self)=='table' and ((type((getmetatable(self) or {}).__call)=='function'))) then
      return self
    end
  end
  return nil
end

function table:maxi() if type(self)~='table' then return nil end; local rv = maxn and maxn(self or {}) or 0; if #(self or {})>rv then rv=#(self or {}) end; return rv end
function table:empty() if type(self)~='table' then return nil end; return type(self)=='table' and type(next(self or {}))=='nil' or false end
function table:indexed() if type(self)~='table' then return nil end; return (type(self)=='table' and (not table.empty(self)) and table.maxi(self)>0) or false end
function table:unindexed() if type(self)~='table' then return nil end; return (type(self)=='table' and (not table.empty(self)) and table.maxi(self)==0) or false end

function table.merge(t1,t2,dup)
	assert(is.iterable(t1))
	assert(is.iterable(t2))
  local rv = table.callable(t1, table)()
  for k,v in pairs(t1) do
    if dup or t2[k] then rv[k]=v end
  end
  if dup then
    for k,v in pairs(t2) do rv[k]=v end
  end
  return rv
end

function table:copy() return table.map(self) end

-- nogmt: do not clone metatable, boolean
function table:clone(nogmt)
  if type(self) ~= 'table' and type(self) ~= 'nil' then return self end
  local rv = table.callable(self, table)()
  for k, v in pairs(self) do
    if k~=nil and v~=nil and k~='__index' then
      rv[k] = table.clone(v, nogmt)
    end
  end
  if not nogmt then
    local gmt = getmetatable(self)
    if gmt then setmetatable(rv, table.clone(gmt, true)) end
  end
  return rv
end

-- accepts f types:
--   is.callable
--   string
-- accepts self types:
--   table
--   iterator function: table:iter, table:values, etc
function table:map(f, ...)
  local rv = table()
  local gg = (not f) and return_self or (is.callable(f) and f or nil)
  if type(self)=='table' then
    for i=1,table.maxi(self) do
      local v=self[i]
      if v~=nil then
        local g = gg or (type(f)=='string' and (type(v)=='table' and v or _G)[f] or nil)
        if is.callable(g) then table.append(rv, g(v, ...)) end
      end
    end
    for i,v in pairs(self) do
      if type(i)~='number' and v~=nil then
        local g = gg or (type(f)=='string' and (type(v)=='table' and v or _G)[f] or nil)
        if is.callable(g) then rv[i] = g(v, ...) end
      end
    end
  elseif type(self)=='function' then
    for v in self do
      if v~=nil then
        local g = gg or (type(f)=='string' and (type(v)=='table' and v or _G)[f] or nil)
        if is.callable(g) then rv:append(g(v, ...)) end
      end
    end
  end
  return rv
end

function table.make_filter(fl) return make_filter(fl) end
function table:filter(f, ...) return table.map(self, make_filter(f), ...) end

function table:flatten(to)
  local rv = to or table.callable(self, table)()
  if type(self)=='table' then
    for k,v in ipairs(self) do if type(v)~='nil' then table.flatten( v, rv ) end end
  else if type(self)~='nil' then rv:append(self) end end
  return rv
end

function table:size()
  local i = 0
  if type(self)=='table' then for k in pairs(self) do i=i+1 end end
  return i
end

-- return up to n values
function table:limit(n)
  if type(n)~='number' or not (n>0) then return self end
  local rv = table.callable(self, table)()
  for i,v in ipairs(self) do
    rv:append(v)
    if #rv>=n then break end
  end
  return rv
end

-- table.trim accepts all self types due to return correct table("x", 7):trim() nonexistent number.trim
function table:trim()
  if type(self) == 'number' then return self end
  if type(self) == 'string' then return string.trim(self) end
  if type(self) == 'table' then
    return (is.callable(self.trim) and self.trim~=table.trim) and self:trim() or table.map(self, table.trim) end
  return self
end

function table:lower()
  if type(self) == 'number' then return self end
  if type(self) == 'string' then return string.lower(self) end
  if type(self) == 'table' then
    return (is.callable(self.lower) and self.lower~=table.lower) and self:lower() or table.map(self, table.lower)
  end
  return self
end

-- FIX return original valuez?
function table:match(...)
  local arg = args(...)
  local rv = table.callable(self, table)()
  for _,v in pairs(self) do
    if type(v)=='string' then
      for _,ma in pairs(arg) do
        if v and v.match then rv:append(v:match(ma)) end
      end
    else
      if v and v.match then rv:append(v:match(table.unpack(arg))) end
    end
  end
  return rv
end

-- just return value, no shift
function table:first(alt) return (type(self)=='table' and self~=table) and self[1] or alt end
function table:last(alt) return (type(self)=='table' and self~=table) and self[#self] or alt end

-- pop last value
function table:pop() if type(self)=='table' and #self>0 then return table.remove(self) end end

function table:reverse()
  local n, m = #self, #self / 2
  for i = 1, m do self[i], self[n - i + 1] = self[n - i + 1], self[i] end
  return self
end

function table:findvalue(x) if type(x)~='nil' then for k, v in pairs(self) do if v == x then return k end end end end

function table:any(...)
  local a = args(...) or {}
  local th = table.tohash(a)
  if type(self)=='table' and type(a)~='nil' then
    for _,v in pairs(self) do
      if th[v] then return true end
    end
  end
  return false
end

function table:all(...)
  local a = args(...) or {}
  local th = table.tohash(a)
  if type(self)=='table' and type(a)~='nil' then
    for _,v in pairs(self) do
      if not th[v] then return false end
    end
  end
  return true
end

function table.ifv(x, a, b) if x then return a else return b end end
function table:append_unique(el) return table.any(self, el) and self or table.append(self, el) end
function table.append(self, el) if type(self)=='table' and type(el)~='nil' then table.insert(self, el) end; return self end
function table.delete(self, ...)
  if select('#', ...)==1 and type(select(1, ...))=='table' then return self:delete(table.unpack(select(1, ...))) end
  for i=1,select('#', ...) do
    local k=select(i, ...)
    if type(k)=='number' then table.remove(self, k) else
    if self[k] then self[k]=nil end
    end
	end
  return self
end
function table:update(...)
  if type(self)=='table' then
    for i=1,select('#', ...) do
      local o = select(i, ...)
      if type(o)=='table' then
        for _,v in ipairs(o) do self:append(v) end
        for k,v in pairs(o) do if type(k)~='number' then self[k]=v end end
      end
    end
  end
  return self
end

-- for i in range(stop) do ... end
-- for i in range(start, stop) do ... end
-- for i in range(start, stop, increment) do ... end
function table.range(...)
  local n = select("#", ...)
  local from, to, increment = 1, nil, 1
  if n == 1 then      to = ...
  elseif n == 2 then  from, to = ...
  elseif n == 3 then  from, to, increment = ...
  else error"range requires 1-3 arguments" end

  local i = from-increment
  return function()
    i = i + increment
    if i>to then return end
    return i
  end
end

-- t:values(true)  -- only string keys
-- t:values(false) -- only numeric keys
-- t:values()      -- both
function table:iter(values, no_number)
  if type(values)=='nil' then values=true end
  if type(self)~='table' then return return_nil end
  local inext, k,v
  if no_number then
    if self.__pairs then
      inext, _, k = pairs(self)
      return function()
        k,v = inext(self,k)
        return values and v or k
      end
    end
    return function(...)
      k,v = next(self, k)
      if k~=nil then
        while no_number==true and type(k)=='number' and k~=nil do k,v = next(self, k) end
        while no_number==false and type(k)~='number' and k~=nil do k,v = next(self, k) end
        return values and v or k
      end
    end
  else
    inext, _, k = ipairs(self)
    return function()
      k,v = inext(self,k)
      return values and v or k
    end
  end
end

function table:values() return table.iter(self, true, true) end
function table:keys() return table.iter(self, false, true) end
function table:ivalues() return table.iter(self, true, false) end
function table:ikeys() return table.iter(self, false, false) end

-- to type set() / hashset()
function table:tohash(value)
  local rv = {}
  value = value~=nil and value or true
  for _,i in pairs(self) do
    if type(i)=='string' then rv[i]=value end
  end
  return rv
end

function table.coalesce(...)
  for i=1,select('#', ...) do
    local v = select(i, ...)
    if v~=nil then
			return v
    end
	end
  return nil
end

function table.zcoalesce(...)
  for i=1,select('#', ...) do
    local v = select(i, ...)
    if toboolean(v) then return v end
	end
  return nil
end

function table.__concat(self, ...)
  local rv = self
  if type(rv)~='table' then rv=table.callable(self, table)() end
  for i=1,select('#', ...) do
    local o = select(i, ...)
    if type(o)=='table' then
      for _,v in ipairs(o) do rv:append(v) end
      for k,v in pairs(o) do if type(k)~='number' and not rv[k] then rv[k]=v end end
    end
  end
  return rv
end

-- honors __iter and item __eq ?
function table.__eq(self, o)
  if type(self)=='table' and getmetatable(self) then
    local mts = getmetatable(self)
    if type(o)=='number' and mts.__tonumber then return tonumber(self)==o end
    if type(o)=='string' then return tostring(self)==o end
    if type(o)=='boolean' then return toboolean(self)==o end
  end
  if type(self)~=type(o) or type(self)~='table' then return false end
  for i,v in pairs(self) do
    local oi = o[i]
    if (type(v)=='table' and not self.__eq(v, oi)) or v~=oi then return false end
  end
  return true
end

local function __newindex(self, k, v) rawset(self, k, v) end
local function __index(self, k) return rawget(self, k) or (type(k)~='number' and rawget(table, k) or nil) end
local function new(_, ...)
  return setmetatable(args(...) or {}, {
    __add = table.append,
    __sub = table.delete,
    __concat = table.__concat,
    __eq = table.__eq,
    __call = new,
    __newindex = __newindex,
    __index = __index,
  })
end

setmetatable(table, {__call=new, __index=table})
