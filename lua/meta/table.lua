require "compat53"
require 'meta.string'
require 'meta.math'

local is = {}
is.callable = function(x) return (type(x)=='function' or (type(x)=='table' and type((getmetatable(x or {}) or {}).__call)=='function')) and true or false end
is.iterable = function(x) return type(x)=='table' or type((getmetatable(x or {}) or {}).__pairs)=='function' end

local function args(...)
  if select('#', ...)==0 then return {} end
  if select('#', ...)==1 and type(select(1, ...))=='table' then return select(1, ...) end
  return {...}
end

local mt = {
  __newindex = function(self, k, v)
    if k and v then
      rawset(self, k, v)
    end
  end,
  __index = function(self, k)
    return rawget(self, k) or rawget(table, k)
  end,
}

function table:new(...) return setmetatable(args(...), mt) end

function table.callable(...)
  for i=1,select('#', ...) do
    local self = select(i, ...)
    if (type(self)=='table' and ((type((getmetatable(self) or {}).__call)=='function'))) then return self end
  end
end

function table:maxi() local rv = table.maxn and table.maxn(self or {}) or 0; if #(self or {})>rv then rv=#(self or {}) end; return rv end
function table:empty() return type(next(self or {}))=='nil' end
function table:indexed() return (not table.empty(self)) and table.maxi(self)>0 or false end
function table:unindexed() return (not table.empty(self)) and table.maxi(self)==0 or false end

function table.merge(t1,t2,dup)
	assert(is.iterable(t1))
	assert(is.iterable(t2))
  local res = {}
  for k,v in pairs(t1) do
    if dup or t2[k] then res[k]=v end
  end
  if dup then
    for k,v in pairs(t2) do res[k]=v end
  end
  return setmetatable(res, getmetatable(t1))
end

function table:copy() return table.map(self) end

-- nogmt: do not clone metatable, boolean
function table:clone(nogmt)
  if type(self) ~= 'table' and type(self) ~= 'nil' then return self end
  local rv = {}
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
  local rv = table.callable(self, table):new()
  if type(self)=='table' then
    for i=1,table.maxi(self) do
      local v=self[i]
      if v~=nil then
        local w = is.callable(v) and v() or v
        local g = type(f)=='string' and (type(w)=='table' and (rawget(w, f) or getmetatable(w)[f]) or rawget(_G, f)) or f
        w = is.callable(g) and g(w, ...) or w
        rv:append(w)
      end
    end
    for i,v in pairs(self) do
      if type(i)~='number' and v~=nil then
        local w = is.callable(v) and v() or v
        local g = type(f)=='string' and (type(w)=='table' and (rawget(w, f) or getmetatable(w)[f]) or rawget(_G, f)) or f
        w = is.callable(g) and g(w, ...) or w
        rv[i] = w
      end
    end
  elseif type(self)=='function' then
    local re = function(x) return x, nil, nil end
    for v in re(self) do
      if v~=nil then
        local g = type(f)=='string' and (type(v)=='table' and (rawget(v, f) or getmetatable(v)[f]) or rawget(_G, f)) or f
        local w = is.callable(g) and g(v, ...) or v
        rv:append(w)
      end
    end
  end
  return rv
end

function table:filter(f, ...)
  local make_filter = function(fl)
    if type(fl)=='nil' then
      return function(v, ...) if type(v)~='nil' then return v end end
    end
    assert(is.callable(fl), 'table:filter make_filter require is.callable')
    return function(v, ...) if type(v)~='nil' and fl(v, ...) then return v end end
  end
  return table.map(self, make_filter(f), ...)
end

function table:flatten(to)
  local rv = to or table.callable(self, table):new()
  if type(self) == 'table' then
    for k,v in ipairs(self) do
      if type(v)~='nil' then table.flatten( v, rv ) end
    end
  else
    if type(self)~='nil' then table.append(rv, self) end
  end
  return rv
end

function table:size()
  local i = 0
  for k in pairs(self) do i = i + 1 end
  return i
end

-- return up to n values
function table:limit(n)
  if type(n)~='number' or not (n>0) then return self end
  local rv = table.callable(self, table):new()
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
    return (is.callable(self.lower) and self.trim~=table.trim) and self:trim() or table.map(self, table.trim) end
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
  local rv = table.callable(self, table):new()
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
function table:first(alt) return #self > 0 and self[1] or alt end
function table:last(alt) return #self > 0 and self[#self] or alt end

-- pop last value
function table:pop() if #self>0 then return table.remove(self) end end

function table:reverse()
  local n, m = #self, #self / 2
  for i = 1, m do self[i], self[n - i + 1] = self[n - i + 1], self[i] end
  return self
end

function table:findvalue(x) if type(x)~='nil' then for k, v in pairs(self) do if v == x then return k end end end end

function table:any(...)
  local a = args(...)
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

function table:append_unique(el) return table.any(self, el) and self or table.append(self, el) end
function table:append(el) if type(el)~='nil' then table.insert(self, el) end; return self end
function table:delete(...)
  if select('#', ...)==1 and type(select(1, ...))=='table' then return self:delete(table.unpack(select(1, ...))) end
  for i=1,select('#', ...) do
    local k=select(i, ...)
    if type(k)=='number' then table.remove(self, k) else
    if self[k] then self[k]=nil end
    end
	end
  return self
end

-- t:values(true)  -- only string keys
-- t:values(false) -- only numeric keys
-- t:values()      -- both
function table:iter(values, no_number)
  if type(values)=='nil' then values=true end
  local iter_next
  local k,v
  iter_next = function(...)
    k,v = next(self, k)
    if k~=nil then
      while no_number==true and type(k)=='number' and k~=nil do k,v = next(self, k) end
      while no_number==false and type(k)~='number' and k~=nil do k,v = next(self, k) end
      return values and v or k
    end
  end
  return iter_next
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

function table.__concat(...)
  local rv = table.callable(select(1, ...), table):new()
  for i=1,select('#', ...) do
    local o = select(i, ...)
    for _,v in ipairs(o) do rv:append(v) end
    for k,v in pairs(o) do if type(k)=='string' and not rv[k] then rv[k]=v end end
  end
  return rv
end

-- honors __iter and item __eq ?
function table:__eq(o)
  if type(self)=='table' and getmetatable(self) then
    local mts = getmetatable(self)
    if type(o)=='number' and mts.__tonumber then return tonumber(self)==o end
    if type(o)=='string' then return tostring(self)==o end
    if type(o)=='boolean' then return toboolean(self)==o end
  end
  if type(self)~=type(o) or type(self)~='table' then return false end
  for i,v in pairs(self) do
    local oi = o[i]
    if (type(v)=='table' and not table.__eq(v, oi)) or v~=oi then return false end
  end
  return true
end

mt.__add = table.append
mt.__sub = table.delete
mt.__call = table.new
mt.__eq = table.__eq
mt.__concat = table.__concat

setmetatable(table, mt)
