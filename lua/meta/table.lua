require "compat53"
require "meta.gmt"
require 'meta.math'
require 'meta.string'
local is = {callable = function(o) return (type(o)=='function' or (type(o)=='table' and type((getmetatable(o) or {}).__call) == 'function')) end}
local clone = require 'meta.clone'

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

function table:save(k,v)
  if type(self)=='nil' or type(k)=='nil' or type(v)=='nil' then return nil end
  assert(type(self)=='table', 'table.save: await table, got %s' % type(self))
  rawset(self, k, v)
  return v end

table.args=args
function table.callable(...)
  for i=1,select('#', ...) do
    local self = select(i, ...)
    if (type(self)=='table' and ((type((getmetatable(self) or {}).__call)=='function'))) then
      return self
    end
  end
  return nil
end

function table.indexable(...)
  for i=1,select('#', ...) do
    local self = select(i, ...)
    if (type(self)=='table' and ((type((getmetatable(self) or {}).__index)=='function') or (type((getmetatable(self) or {}).__index)=='table') )) then
      return self
    end
  end
  return nil
end

function preserve(self)
  return (type(self)=='table' and getmetatable(self) and getmetatable(self).__preserve) and self() or table()
end

function table:of(o) if is.callable(o) then return clone(self, {__item=o}) end end

function table:maxi() if type(self)~='table' then return nil end; local rv = maxn and maxn(self or {}) or 0; if #(self or {})>rv then rv=#(self or {}) end; return rv end
function table:empty() return (type(self)=='table' and type(next(self or {}))=='nil') and true or nil end
function table:indexed() if type(self)~='table' then return nil end; return (type(self)=='table' and (not table.empty(self)) and table.maxi(self)>0) or false end
function table:unindexed() if type(self)~='table' then return nil end; return (type(self)=='table' and (not table.empty(self)) and table.maxi(self)==0) or false end
function table:iindexed() if type(self)~='table' then return end; local it=ipairs((self)); return type((it(self,0)))=='number' end

function table.merge(t1,t2,dup)
--	assert(is.iterable(t1))
--	assert(is.iterable(t2))
--  local rv = table.callable(t1, table)()
  local rv = preserve(t1)
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
  local rv = table()
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

-- clone(set, {__item=tostring})
function table:rawclone(o, nogmt)
  if type(self)~='table' then return self end
  local rv = (type(o)~='nil' and nogmt) and clone(o, nil, nogmt) or {}
  for k, v in pairs(self) do
    if k~=nil and v~=nil and (k~='__index' or nogmt) then
      if not rawget(rv, k) then
        v = assert(clone(v))
        rawset(rv, k, v)
      end
    end
  end
  if not nogmt then
    local gmt = getmetatable(self)
    if gmt or o then
      setmetatable(rv, assert(clone(gmt, o, true)))
    else
      local k = '__index'
      local v = rawget(self, k)
      if v and not rawget(rv, k) then
        rv.__index=clone(v)
        setmetatable(rv, rv)
      end
    end
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
  local rv=preserve(self)
  local gg = (not f) and return_self or (is.callable(f) and f or nil)
  if type(self)=='function' then
    for v in self do
      local g = gg or (type(f)=='string' and (type(v)=='table' and v or _G)[f] or nil)
      if is.callable(g) then local r = g(v, ...)
        if (getmetatable(rv) or {}).__add then _=rv+r
        elseif rv.append then table.append(rv, r)
        else table.insert(rv, r) end
      end
    end
    return rv
  end
  if select('#', ...)>0 then return table.multiargmap(self, f, ...) end
  local ipaired
  self=self or {}
  local gmt=(getmetatable(type(self)=='table' and self or {}) or {})
  if ((not is.callable(gmt.__pairs)) or gmt.__pairs==ipairs) then
    if is.callable(gmt.__iter) then
      if gmt.__preserve then
        if gmt.__concat then return rv .. table.map(gmt.__iter(self), f, ...)
        elseif gmt.__add then
          local __iter=gmt.__iter(self)
          for v in __iter do
            local g = gg or (type(f)=='string' and (type(v)=='table' and v or _G)[f] or nil)
            if is.callable(g) then _=rv+g(v, ...) end
          end
          return rv
        end
      end
    else
      for i=1,table.maxi(self) do
        local v=self[i]
        local g = gg or (type(f)=='string' and (type(v)=='table' and v or _G)[f] or nil)
        if is.callable(g) then
          ipaired=true
          local r = g(v, ...)
          if (getmetatable(rv) or {}).__add then _=rv+r
          elseif rv.append then table.append(rv, r)
          else table.insert(rv, r) end
      end end end
    if ipaired then return rv end
  end
  for k,v in pairs(self) do
    local g = gg or (type(f)=='string' and (type(v)=='table' and v or _G)[f] or nil)
    if is.callable(g) then rv[k]=g(v, k) end
  end
  return rv
end

function table:multiargmap(f, ...)
  local rv=preserve(self)
  local gg = (not f) and return_self or (is.callable(f) and f or nil)
  local gmt=(getmetatable(type(self)=='table' and self or {}) or {})
  local __iter=gmt.__iter
  if is.callable(__iter) and not is.callable(gmt.__pairs) then self=__iter(self) end
  if type(self)=='table' then
    for i,v in ipairs(self) do
      if v~=nil then
        local g = gg or (type(f)=='string' and (type(v)=='table' and v or _G)[f] or nil)
        if is.callable(g) then
          local r = g(v, ...)
          if (getmetatable(rv) or {}).__add then
            _=rv+r
          elseif rv.append then table.append(rv, r) else
            table.insert(rv, r)
          end
        end
      end
    end
    for i,v in pairs(self) do
      if type(i)~='number' and v~=nil then
        local g = gg or (type(f)=='string' and (type(v)=='table' and v or _G)[f] or nil)
        if is.callable(g) then
          rv[i] = g(v, ...)
        end
      end
    end
  elseif type(self)=='function' then
    for v in self do
      if v~=nil then
        local g = gg or (type(f)=='string' and (type(v)=='table' and v or _G)[f] or nil)
        if is.callable(g) then
          local r = g(v, ...)
          if r then
            if (getmetatable(rv) or {}).__add then _=rv+r
            elseif rv.append then rv:append(r)
            else table.insert(rv, r); end
          end
        end
      end
    end
  end
  return rv
end

function table.make_filter(fl) return make_filter(fl) end
function table:filter(f, ...) return table.map(self, make_filter(f), ...) end

function table:find(it, alt)
  if is.callable(it) then
    for k,v in pairs(self) do
      if it(v) then return v, k end
    end
  end
  return alt
end

function table:reduce(it, acc)
  local start=1
  if not acc then
    acc=acc or self[start]
    start=start+1
  end
  for i=start,#self do
    acc = it(acc, self[i])
  end
  return acc
end

function table:flatten(to)
  local rv = to or preserve(self)
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

-- return iterator for tuple
function table.tuple(...) return table.ivalues({...}) end

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
  local rv = preserve(self)
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
function table:first(alt) return (type(self)=='table' and not rawequal(self, table)) and self[1] or alt end
function table:last(alt) return (type(self)=='table' and not rawequal(self, table)) and self[#self] or alt end

-- pop last value
function table:pop() if type(self)=='table' and #self>0 then return table.remove(self) end end

function table:reverse()
  local n, m = #self, #self / 2
  for i = 1, m do self[i], self[n - i + 1] = self[n - i + 1], self[i] end
  return self
end

function table:findvalue(x) if type(x)~='nil' then for k, v in pairs(self) do if v == x then return k end end end end

function table:any(...)
  local a = args(...) or table()
  local th = table.tohash(a)
  if type(self)=='table' and type(a)~='nil' then
    for _,v in pairs(self) do
      if th[v] then return true end
    end
  end
  return false
end

function table:all(...)
  local a = args(...) or table()
  local th = table.tohash(self, true)
  if type(self)=='table' and type(a)~='nil' then
    for _,v in pairs(a) do
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
        for k,v in pairs(o) do if type(k)~='number' then self[k]= ((v~=false) and v or nil) end end
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

-- t:values(true)  -- only non-numeric keys
-- t:values(false) -- only numeric keys
-- t:values()      -- both
function table:iter(values, no_number)
  if type(self)~='table' then return return_nil end
  if type(values)=='nil' and type(no_number)=='nil' then
    local __iter=(getmetatable(type(self)=='table' and self or {}) or {}).__iter
    if is.callable(__iter) then return __iter(self) end
  end
  if type(values)=='nil' then values=true end
  local inext, k,v
  if no_number then
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
    assert(type(inext)=='function', 'inext is not function')
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

function table:nextstring(cur)
  local k,v = cur
  repeat k,v = next(self, k)
  until type(k)=='string' or type(k)=='nil'
  return k,v
end

-- to type set() / hashset()
function table:tohash(value)
  local rv = {}
  value = value~=nil and value or true
  for _,i in pairs(self or {}) do
    rv[i]=value
  end
  return rv
end

function table:sorted(...)
  table.sort(self, ...)
  return self
end

function table:uniq()
  local rv = table{}
  for _,it in ipairs(self) do rv:append_unique(it) end
  return rv
end
function table:null() if type(next(self))~='nil' then return self end end

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
    if v then return v end
	end
  return nil
end

-- recursively remove mt from internal tables
-- table t installed to self (best for __index)
function table:mtremove(t, deep)
  if type(self)~='table' then return self end
  setmetatable(self, nil)
  if type(t)=='table' then table.update(self, t) end
  return self
end

local function compare(t1,t2,ignore_mt,cycles,thresh1,thresh2)
  local ty1 = type(t1)
  local ty2 = type(t2)
  -- non-table types can be directly compared
  if ty1 ~= 'table' or ty2 ~= 'table' then return t1 == t2 end
  local mt1 = debug.getmetatable(t1)
  local mt2 = debug.getmetatable(t2)
  -- would equality be determined by metatable __eq?
  if mt1 and mt1 == mt2 and mt1.__eq then
    -- then use that unless asked not to
    if not ignore_mt then return t1 == t2 end
  else -- we can skip the deep comparison below if t1 and t2 share identity
    if rawequal(t1, t2) then return true end
  end

  -- handle recursive tables
  cycles = cycles or {{},{}}
  thresh1, thresh2 = (thresh1 or 1), (thresh2 or 1)
  cycles[1][t1] = (cycles[1][t1] or 0)
  cycles[2][t2] = (cycles[2][t2] or 0)
  if cycles[1][t1] == 1 or cycles[2][t2] == 1 then
    thresh1 = cycles[1][t1] + 1
    thresh2 = cycles[2][t2] + 1
  end
  if cycles[1][t1] > thresh1 and cycles[2][t2] > thresh2 then
    return true
  end

  cycles[1][t1] = cycles[1][t1] + 1
  cycles[2][t2] = cycles[2][t2] + 1

  for k1,v1 in next, t1 do
    local v2 = t2[k1]
    if v2 == nil then
      return false, {k1}
    end

    local same, crumbs = compare(v1,v2,nil,cycles,thresh1,thresh2)
    if not same then
      crumbs = crumbs or {}
      table.insert(crumbs, k1)
      return false, crumbs
    end
  end
  for k2,_ in next, t2 do
    -- only check whether each element has a t1 counterpart, actual comparison
    -- has been done in first loop above
    if t1[k2] == nil then return false, {k2} end
  end
  cycles[1][t1] = cycles[1][t1] - 1
  cycles[2][t2] = cycles[2][t2] - 1
  return true
end

function table.equal(a, b) if type(a)=='table' and type(b)=='table' then return compare(a, b, true) else return a==b end end

local function __append(self, it)
  if getmetatable(self).__add then return self+it end
  if self.append then return self:append(it) end
  table.insert(self, it)
  return self
end

function table.__concat(...)
  local self=select(1, ...)
  local rv = preserve(self)
  for i=1,select('#', ...) do
    local o = select(i, ...)
    if type(o)=='table' then
      if o[1] then for _,v in ipairs(o) do __append(rv, v) end end
      for k,v in pairs(o) do if type(k)~='number' then rv[k]=v end end
    end
    if type(o)=='function' then
      for k,v in o do
        if type(k)~='nil' and type(v)~='nil' then
          rv[k]=v
        elseif type(k)~='nil' then
          __append(rv, k)
        end
      end
    end
  end
  return rv
end

-- honors __iter and item __eq ?
function table.__eq(self, o)
  if type(self)~='table' and type(o)~='table' then return self==o end
  if type(self)=='table' and getmetatable(self) then
    local mts = getmetatable(self)
    if type(o)=='number'  and is.callable(mts.__tonumber)  then return mts.__tonumber(self)==o end
    if type(o)=='string'  and is.callable(mts.__tostring)  then return mts.__tostring(self)==o end
    if type(o)=='boolean' then
      if is.callable(mts.__toboolean) then return mts.__toboolean(self)==o end
      return type(next(self))~='nil' == o
    end
  end
  if type(self)~=type(o) or type(self)~='table' then return false end
  return table.equal(self, o)
end
local function __tostring(self) return string.format('table(%s)', table.concat(self, ',')) end
local function __index(self, k)
  if type(self)~='table' then return nil end
  if type(k)=='number' then return rawget(self, k) end
  return rawget(self, k) or rawget(table, k)
end
return setmetatable(table, {
  __name= 'table',
  __add = table.append,
  __sub = table.delete,
  __concat = table.__concat,
  __eq = table.__eq,
  __export = function(self) return setmetatable(clone(self, nil, true), nil) end,
  __index = __index,
  __tostring = __tostring,
  __mul = table.map,
  __mod = table.filter,
  __call = function(self, ...) return setmetatable(args(...), getmetatable(self)) end,
})
