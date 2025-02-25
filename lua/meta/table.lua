require "compat53"
require "meta.gmt"
require 'meta.math'
require 'meta.string'

local iter, is

local lazy = require 'meta.lazy'
local meta = lazy('meta')
_ = meta .. 'mt'
is = meta .. 'is'

local maxn = rawget(table, 'maxn')

--local index = require "meta.mt.i"
local index = meta.mt.i

local function swap(a,b) return b,a end
local function mt(t) return is.complex(t) and getmetatable(t) or {} end
local function argz(...) local rv={...}; return (#rv==1 and is.table(rv[1])) and rv[1] or rv end
local function maxi(self) return is.table(self) and (maxn and maxn(self) or #self) end
table.maxi = maxi

-- __preserve=true: try to preserve argument type (specific array/set/hash/list should use it), not for loader/modules/mcache/etc
local function preserve(self, alt) return (is.table(self) and getmetatable(self) and mt(self).__preserve) and setmetatable({},getmetatable(self)) or alt or table() end
table.preserve = preserve

if (not (meta%'iter')) and not table.iter then
  iter          = meta.iter
  table.iter    = iter
  table.map     = iter.map
  table.filter  = iter.filter
end

is.ipaired  = function(t) if is.table(t) then -- honor __pairs/__ipairs and check __pairs==ipairs
    local pairz, ipairz = mt(t).__pairs, mt(t).__ipairs
    return (pairz==ipairs or ipairz) and true or nil
  end end
is.paired   = function(t) if is.table(t) then return (mt(t).__pairs and not is.ipaired(t)) and true or nil end end

--[[
is = {
  callable = require "meta.is.callable",
  func     = function(o) return type(o)=='function' or nil end,
  number   = function(o) return type(o)=='number' or nil end,
  string   = function(o) return type(o)=='string' or nil end,
  integer  = function(o) return type(o)=='number' and math.floor(o)==o end,
  table    = function(o) return type(o)=='table' or nil end,
  complex  = function(o) return type(o)=='table' or type(o)=='userdata' or nil end,
  iter     = function(x) return x and rawequal(getmetatable(iter),getmetatable(x)) or nil end,
  ipaired  = function(t) if is.table(t) then -- honor __pairs/__ipairs and check __pairs==ipairs
    local pairz, ipairz = mt(t).__pairs, mt(t).__ipairs
    return (pairz==ipairs or ipairz) and true or nil
  end end,
  paired   = function(t) if is.table(t) then return (mt(t).__pairs and not is.ipaired(t)) and true or nil end end,
  iterable = function(t) return (is.table(t) and mt(t).__iter) and true or nil end,
  bulk     = require "meta.is.bulk",
}
--]]

-- exported checkers
function table:plain()     return type(self)=='table' and not getmetatable(self) end
function table:empty()     return self and is.table(self) and type(next(self))=='nil' and true or nil end
function table:unindexed() return is.table(self) and (not table.empty(self)) and table.maxi(self)==0 end
function table:indexed()   return is.table(self) and (not table.empty(self)) and (is.ipaired(self) or type(self[1])~='nil') end -- TODO: check why this true for nil

-- table action closures: best for map/cb/gsub/...
function table:appender()  return function(...) return table.append(self, ...)  end end
function table:saver()     return function(...) return table.save(self, ...)    end end
function table:uappender() return function(...) return table.append_unique(self, ...) end end
function table:deleter()   return function(...) return table.delete(self, ...)  end end
function table:updater()   return function(...) return table.update(self, ...)  end end

-- derive typed table (array/set/etc)
function table:of(o) if is.table(self) and is.callable(o) then return table.clone(self, {__item=o}) end end

-- match notation of specials like loader/mcache/wrappers/etc
function table:save(k,v)
  if (not is.table(self)) or type(k)=='nil' or type(v)=='nil' then return nil end
  rawset(self, k, v); return v
  end

-- respects v/vk/vi
function table:append(v, k) if is.table(self) then if type(v)~='nil' then
  if type(k)~='nil' and type(k)~='number' then
    self[k]=v
  else
    if type(k)=='number' and k<=#self+1 then
      if k<1 then k=1 end
      table.insert(self, k, v)
    else
      if mt(self).__add and mt(self).__add~=table.append and mt(self).__add~=table.append_unique then return self+v end
      table.insert(self, v)
    end
  end
end end return self end

function table:append2(v, k) if is.table(self) then if type(v)~='nil' then
  if type(k)~='nil' and type(k)~='number' then
    self[k]=v
  else
    if type(k)=='number' and k<=#self+1 then
      if k<1 then k=1 end
      table.insert(self, k, v)
    else
      table.insert(self, #self+1, v)
    end
  end
end end return self end

function table:append_unique(v) if type(v)~='nil' and not table.any(self, v) then table.append(self, v) end; return self end

function table:delete(...) if is.table(self) then
  for b in iter.tuple(...) do
    if is.integer(b) then
      local i = index(self, b)
      if i and i>0 and i<=#self then
        table.remove(self, i)
      end
    elseif is.table(b) then
      for i,k in ipairs(b) do
        table.delete(self, k)
      end
      for k,v in pairs(b) do
        if not is.integer(k) then
          table.delete(self[k], v)
        end
      end
    elseif type(b)~='nil' then
      self[b]=nil
    end
  end end
  return self
end

-- try to match even paired+ipared tables
function table:update(...) if is.table(self) then
  for it in iter.tuple(...) do if type(it)=='table' then
    if table.indexed(it) then for v in table.iter(it) do table.append(self, v) end end
    for k,v in pairs(it) do if type(k)~='number' then self[k]=v end end
	end end; return self end end


-- searchers/selectors
function table.find(...) return swap(iter.find(...)) or nil end

-- find first index for any arg elements
function table:any(...)
  if not is.table(self) then return nil end
  local z = table.hashed(argz(...), true)
  return table.find(self, function(i) return z[i] end)
end

function table:all(...)
  if not is.table(self) then return true end
  local z = table.hashed(self, true)
  return (not table.find(argz(...) or table(), function(i) return not z[i] end)) or nil
end

function table:index(i) if type(self)=='table' and type(i)=='number' then
  return rawget(self, index(self, i))
end end

function table:interval(ii) if type(self)=='table' and type(ii)=='table' then
  local i,j = ii[1] or 1, ii[2] or #self
  if type(i)=='number' then return table.sub(self, i,j) end
end end

-- like string.sub for table
-- todo: boundary control
function table:sub(i,j)
  if type(self)~='table' then return nil end
  local rv = preserve(self, {})
  if #self==0 then return rv end
  i=i or 1
  j=j or #self
  if type(i)~='number' or type(j)~='number' then return nil end
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
  until type(v)~='nil' or i>maxi(self)
  if type(i)=='number' and i>maxi(self) then return nil, nil end
  return i,v
end

function table:nextistrings(cur)
  local k,v = cur
  if k==#self or type(k)=='string' then
    repeat k,v = next(self, k)
    until type(k)=='string' or type(k)=='nil'
    return k,v
  end
  k=k or 0
  if #self>0 and type(k)=='number' and k<#self then
    repeat k = k+1; v=self[k]
    until type(v)~='nil' or k>#self
    if type(k)=='number' and k>#self then return nil, nil end
  end
  return k,v
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
  local rv = type(to)=='table' and to or preserve(self)
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
  if type(value)=='nil' then value=true end
  for i in iter.ivalues(self) do rv[i]=value end
  return rv
end

function table:sorted(...)
  table.sort(self, ...)
  return self
end

function table:uniq()
  local rv = preserve(self)
  local seen = {}
  for _,it in ipairs(self) do
    if not seen[it] then
      table.append(rv, it)
      seen[it]=true
    end
  end
  return rv
end

-- TODO: remove install logic
-- recursively remove mt from internal tables
-- table t installed to self (best for __index)
function table:mtremoved(tt, deep)
  if type(self)~='table' then return self end
  setmetatable(self, nil)
  if type(tt)=='table' then table.update(self, tt) end
  return self
end

-- clone table with mt by default
-- nogmt=true to drop mt
local function clone(self, o, nogmt)
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

function table.equal(a, b) if type(a)=='table' and type(b)=='table' then
  return compare(a, b, true) else return a==b end end

local function __concat(a, b)
  if type(a)=='table' then
    if is.bulk(b) then
      for v,k in iter(b) do
        table.append(a, v, type(k)~='number' and k or nil)
      end
    end
  end
  return a or b
end

local function __index(self, k)
  return rawget(table, k) or rawget(self, index(self, k)) or table.interval(self, k)
end

return setmetatable(table, {
  __add = table.append,
  __array = true,
  __call = function(self, ...) return setmetatable(argz(...), getmetatable(self)) end,
  __concat = __concat,
  __eq = table.equal,
  __export = function(self) return setmetatable(clone(self, nil, true), nil) end,
  __index = __index,
  __iter = iter.items,
  __div = iter.first,
  __mul = iter.map,
  __mod = iter.filter,
  __name= 'table',
  __preserve = true,
  __tostring = function(self) return table.concat(self, "\n") end,
  __sub = table.delete,
})