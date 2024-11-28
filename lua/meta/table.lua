require "compat53"
require "meta.gmt"
require 'meta.math'
require 'meta.string'

-- local helpers
local is, clone, mt, args, maxi, preserve, make_filter
local maxn = rawget(table, 'maxn')
local unpack = table.unpack or unpack
local pack = table.pack or pack
local _ = pack
local fn = {
  same=function(...) return ... end,
  self=function(x) return x end,
  null=function() return end,
}
is = {
  callable = require "meta.is.callable",
  table = function(o) return type(o)=='table' or nil end,
  data = function(o) return type(o)=='table' or type(o)=='userdata' or nil end,
  ipaired = function(t) if is.table(t) then -- honor __pairs/__ipairs and check __pairs==ipairs
    local pairz, ipairz = mt(t).__pairs, mt(t).__ipairs
    return (pairz==ipairs or ipairz) and true or nil
  end end,
  paired = function(t) if is.table(t) then return (mt(t).__pairs and not is.ipaired(t)) and true or nil end end,
  iterable = function(t) return (is.table(t) and mt(t).__iter) and true or nil end,
}
function mt(t) return is.data(t) and getmetatable(t) or {} end
function args(...) local rv={...}; return (#rv==1 and is.table(rv[1])) and rv[1] or rv end
function maxi(self) return is.table(self) and (maxn and maxn(self) or #self) end
--math.max(maxn and maxn(self) or 0, #self) end
table.maxi=maxi

-- __preserve=true: try to preserve argument type (specific array/set/hash/list should use it), not for loader/modules/cache/etc
local function preserve(self)
--  print('PRESERVE', getmetatable(self).__name, (is.table(self) and getmetatable(self) and mt(self).__preserve))
  return (is.table(self) and getmetatable(self) and mt(self).__preserve) and self() or table() end

-- table.map action from predicate: note argument order: natural iterator return items, numeric keys optional and ignored in return
function make_filter(fl)
  if not is.callable(fl) then return fn.self end
  return function(v, k) if fl(v, k) then return v, type(k)~='number' and k or nil end end
  end

-- exported checkers
function table:empty()     return self and is.table(self) and type(next(self))=='nil' and true or nil end
function table:unindexed() return is.table(self) and (not table.empty(self)) and table.maxi(self)==0 end
function table:indexed()   return is.table(self) and (not table.empty(self)) and (is.ipaired(self) or type(self[1])~='nil') end -- TODO: check why this true for nil

-- return iterator for tuple
function table.tuple(...)  return table.ivalues({...}) end

-- table action closures: best for map/cb/gsub/...
function table:appender()  return function(...) return table.append(self, ...)  end end
function table:saver()     return function(...) return table.save(self, ...)    end end
function table:uappender() return function(...) return table.append_unique(self, ...) end end
function table:deleter()   return function(...) return table.delete(self, ...)  end end
function table:updater()   return function(...) return table.update(self, ...)  end end

-- derive typed table (array/set/etc)
function table:of(o) if is.table(self) and is.callable(o) then return clone(self, {__item=o}) end end

local oktype={table=true,['function']=true,userdata=true}
-- data source: table or iterator
-- caller: callable
-- TODO: add standard metatabled userdata operations
function table:map(f)
  if not oktype[type(self)] then return {} end
  local rv=preserve(self)
  f=is.callable(f) and f or fn.same
  if type(self)=='userdata' then
    local it=mt(self).__iter
    if not it then return {} end
    self=it(self)
  end
  if type(self)=='function' then
    for it in self do table.append(rv, f(it)) end
    return rv
  end
  local ipaired
  self=self or {}
  local gmt=mt(self)
  if (not is.callable(gmt.__pairs)) and (gmt.__pairs==ipairs or maxi(self)>0 or gmt.__iter) then
    local iter=gmt.__iter
    if is.callable(iter) then
      if gmt.__preserve then
        if gmt.__concat then return rv .. table.map(iter(self), f)
        elseif gmt.__add then
          for it in iter(self) do table.append(rv, f(it)) end
          return rv
        end
      end
    else
      for i=1,maxi(self) do
        ipaired=true
        table.append(rv, f(self[i]))
      end
    end
    if ipaired then return rv end
  end
  for k,v in pairs(self) do
    table.append(rv, f(v, k), k)
  end
  return rv
end

--function table.make_filter(fl) return make_filter(fl) end
function table:filter(f)
  if type(self)~='table' and type(self)~='function' then return end
  if type(f)=='number' then return end
  if type(f)=='string' and #f==0 then return end
  if type(f)=='string' and #f>0 then f={f} end
  if type(f)=='table' and not getmetatable(f) then
    local rv = preserve(self)
    for _,k in ipairs(f) do rv[k]=self[k] end
    return rv
  end
  if not is.callable(f) then return end
  return table.map(self, f and make_filter(f))
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

function table:find(it)
  if not is.callable(it) and type(it)~='nil' then
    local itit=it
    it=function(x) return itit==x end
  end
  if is.callable(it) then
    for k,v in pairs(self) do
      if it(v) then return k,v end
    end
  end
  return nil
end

-- find first index for any arg elements
function table:any(...)
  local a = args(...)
  if #a==0 or not is.table(self) then return nil end
  local th = table.hashed(a)
  for k,v in pairs(self) do
    if th[v] then return k end
  end
  return nil
end

function table:all(...)
  local a = args(...) or table()
  local th = table.hashed(self, true)
  if type(self)=='table' and type(a)~='nil' then
    for _,v in pairs(a) do
      if not th[v] then return false end
    end
  end
  return true
end

-- respects both v and kv
function table:append(v, k) if is.table(self) then if type(v)~='nil' then
  if k and type(k)~='number' then
    self[k]=v
  else
    if mt(self).__add and mt(self).__add~=table.append and mt(self).__add~=table.append_unique then return self+v end
    table.insert(self, v)
  end
end end return self end

-- match notation of specials like loader/cache/wrappers/etc
function table:save(k,v)
  if (not is.table(self)) or type(k)=='nil' or type(v)=='nil' then return nil end
  rawset(self, k, v); return v
  end

function table:append_unique(v) return table.any(self, v) and self or table.append(self, v) end
function table:delete(...) if is.table(self) then
  local len, o = select('#', ...), ...
  if len==1 and is.table(o) then return table.delete(self, unpack(o)) end
  for k in table.tuple(...) do
    if type(k)=='number' then table.remove(self, k) else self[k]=nil end
	end; return self end end

-- try to match even paired+ipared tables
function table:update(...) if is.table(self) then
  for it in table.tuple(...) do if type(it)=='table' then
    if table.indexed(it) then for v in table.iter(it) do table.append(self, v) end end
    for k,v in pairs(it) do if type(k)~='number' then self[k]=v end end
	end end; return self end end

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

-- string.sub for table
-- todo: boundary control
function table:sub(i,j)
  local a,b=i,j
  if type(self)~='table' then return nil end
  local rv={} --preserve(self)
  if #self==0 then return rv end
  i=i or 1
  j=j or #self
  if type(i)~='number' or type(j)~='number' then return rv end
  if i<0 then i=(#self+1)+i end; if i<1 then i=1 end
  if j<0 then j=(#self+1)+j end; if j<1 then j=1 end
  if i>#self then i=#self end
  if j>#self then j=#self end
  while i<=j do
    table.insert(rv, self[i])
    i=i+1
  end
  return rv
end

-- t:values(true)  -- only non-numeric keys
-- t:values(false) -- only numeric keys
-- t:values()      -- both
--
-- without arguments use __iter, __pairs or guess for ipairs
function table:iter(values, no_number)
  if type(self)~='table' and type(self)~='userdata' then return fn.null end
  if type(self)=='userdata' or type(values)=='nil' and type(no_number)=='nil' then
    local iter=mt(self).__iter
--(getmetatable(self) or {}).__iter
    if is.callable(iter) then return iter(self) end
--    if type(self)=='userdata' then return fn.null end
  end
  local ok
  local pairz=mt(self).__pairs
  local inext, k, v, tab
  if no_number then
    ok=function(i,o) return type(i)~='number' and type(o)~='nil' end
    pairz=pairz or table.stringpairs
  else
    ok=function(i,o) return type(i)=='number' and type(o)~='nil' end
    pairz=pairz or mt(self).__ipairs or table.ipairs
  end
  do
    inext, tab, k = pairz(self)
    return function(...)
      repeat k,v = inext(tab, k)
      until ok(k,v) or type(k)=='nil'
      if type(values)=='nil' then return v,k end
      if values then return v else return k end
    end
  end
end

function table:values() return table.iter(self, true, true) end
function table:keys() return table.iter(self, false, true) end
function table:ivalues() return table.iter(self, true, false) end
function table:ikeys() return table.iter(self, false, false) end

-- next/pairs section
-- name next*
function table:nextstring(cur)
  local k,v = cur
  repeat k,v = next(self, k)
  until type(k)=='string' or type(k)=='nil'
  return k,v
end

function table:nexti(cur)
  local i,v = cur
  repeat i = (i or 0)+1; v=self[i]
  until type(v)~='nil' or i>#self
  if type(i)=='number' and i>#self then return nil, nil end
  return i,v
end

function table:nextirev(cur)
  if type(cur)=='nil' then return 1, self[#self] end
  if type(cur)=='number' then
    if math.ceil(cur)~=cur then return nil, nil end
    if cur==#self then return nil, nil end
    return cur+1, self[#self-cur]
  end
  return nil
end

-- name *pairs
function table:irevpairs() return table.nextirev, self end
function table:ipairs() return table.nexti, self end
function table:stringpairs() return table.nextstring, self end
function table:autopairs()
  local nexter, indexed = next, (#self>0 or type(self[1])~='nil')
  if indexed then nexter=table.nexti end
  return nexter, self
  end

-- consistent with string:null()
function table:nulled() if is.table(self) and type(next(self))~='nil' then return self end end

function table:flattened(to)
  local rv = to or preserve(self)
  if type(self)=='table' then
    for k,v in ipairs(self) do if type(v)~='nil' then table.flattened(v, rv) end end
  else if type(self)~='nil' then table.insert(rv, self) end end
  return rv
end

function table:reversed()
  local n, m = #self, #self / 2
  for i = 1, m do self[i], self[n - i + 1] = self[n - i + 1], self[i] end
  return self
end

-- to type set() / hashset()
function table:hashed(value)
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

-- should be done with seen(...)
function table:uniq()
  local rv = table{}
  for _,it in ipairs(self) do rv:append_unique(it) end
  return rv
end

-- TODO: remove install logic
-- recursively remove mt from internal tables
-- table t installed to self (best for __index)
function table:mtremoved(t, deep)
  if type(self)~='table' then return self end
  setmetatable(self, nil)
  if type(t)=='table' then table.update(self, t) end
  return self
end

-- clone table with mt by default
-- nogmt=true to drop mt
function clone(self, o, nogmt)
  if type(self)~='table' then return self end
  local rv = (type(o)~='nil' and nogmt) and clone(o, nil, nogmt) or {}
  for k, v in pairs(self) do
    if k~=nil and v~=nil and (k~='__index' or nogmt) then
      if not rawget(rv, k) then
        v = clone(v)
        rawset(rv, k, v)
      end
    end
  end
  if not nogmt then
    local gmt = getmetatable(self)
    if gmt or o then
      setmetatable(rv, clone(gmt, o, true))
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
table.clone=clone

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

local function __concat(...)
  local self=select(1, ...)
  local rv = preserve(self)
  for i=1,select('#', ...) do
    local o = select(i, ...)
    if type(o)=='table' then
      if o[1] then for _,v in ipairs(o) do table.append(rv, v) end end
      for k,v in pairs(o) do if type(k)~='number' then rv[k]=v end end
    end
    if type(o)=='function' then
      for v,k in o do
        table.append(rv, v, k)
      end
    end
  end
  return rv
end

-- honors __iter and item __eq ?
local function __eq(self, o)
  if type(self)~='table' and type(o)~='table' then return self==o end
  if type(self)=='table' and getmetatable(self) then
    local gmt = mt(self)
    if type(o)=='number'  and is.callable(gmt.__tonumber) then return gmt.__tonumber(self)==o end
    if type(o)=='string'  and is.callable(gmt.__tostring) then return gmt.__tostring(self)==o end
    if type(o)=='boolean' then
      if is.callable(gmt.__toboolean) then return gmt.__toboolean(self)==o end
      return type(next(self))~='nil' == o
    end
  end
  if type(self)~=type(o) or type(self)~='table' then return false end
  return table.equal(self, o)
end

local function __index(self, k) if is.table(self) then
  if type(k)=='number' then return rawget(self, k)
  else return rawget(table, k) end end end

return setmetatable(table, {
  __add = table.append,
  __call = function(self, ...) return setmetatable(args(...), getmetatable(self)) end,
  __concat = __concat,
  __eq = __eq,
  __export = function(self) return setmetatable(clone(self, nil, true), nil) end,
  __index = __index,
  __mul = table.map,
  __mod = table.filter,
  __name= 'table',
  __tostring = function(self) return table.concat(self, "\n") end,
  __sub = table.delete,
})