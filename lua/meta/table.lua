require "compat53"
require "meta.gmt"
require 'meta.math'
require 'meta.string'

local iter = require 'meta.iter'
local meta = require 'meta.lazy'
local is, fn, pkg, mmt = meta({'is', 'fn', 'table', 'mt'})

local index, preserve, maxi = mmt.i, pkg.preserve, pkg.maxi
local mt, args, swap = table.unpack(fn[{'mt','args','swap'}])

-- rm
is.ipaired  = function(t) if is.table(t) then -- honor __pairs/__ipairs and check __pairs==ipairs
    local pairz, ipairz = mt(t).__pairs, mt(t).__ipairs
    return (pairz==ipairs or ipairz) and true or nil
  end end
is.paired   = function(t) if is.table(t) then return (mt(t).__pairs and not is.ipaired(t)) and true or nil end end

-- exported checkers
function table:plain()     return type(self)=='table' and not getmetatable(self) end
function table:empty()     return self and is.table(self) and type(next(self))=='nil' and true or nil end
function table:unindexed() return is.table(self) and (not table.empty(self)) and maxi(self)==0 end
function table:indexed()   return is.table(self) and (not table.empty(self)) and (is.ipaired(self) or type(self[1])~='nil') end -- TODO: check why this true for nil
-- is.ordered?

-- table action closures: best for map/cb/gsub/...
function table:caller()    return is.callable(self) and function(...) return self(...) end or nil end
function table:getter()    return function(k)   return self[k], k               end end
function table:appender()  return function(...) return table.append(self, ...)  end end
function table:saver()     return function(...) return table.save(self, ...)    end end
function table:uappender() return function(...) return table.append_unique(self, ...) end end
function table:deleter()   return function(...) return table.delete(self, ...)  end end
function table:updater()   return function(...) return table.update(self, ...)  end end

-- uses iter arguments order (v,k)
table.save    = require('meta.table.save')
table.append  = table.append or require('meta.table.append')

--[[
-- respects v/vk/vi
function table:append(v, k) if type(self)=='table' then if type(v)~='nil' then
  if type(k)~='nil' and type(k)~='number' then
    self[k]=v
  else
    if type(k)=='number' and k<=#self+1 then
      if k<1 then k=1 end
      table.insert(self, k, v)
    else
      local add=mt(self).__add
      if add and add~=table.append and add~=table.append2 and add~=table.append_unique then return self+v end
      table.insert(self, v)
    end
  end
end end return self end
--]]

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

function table:append_unique(v) if type(v)~='nil' and not table.any(self, v) then table.append2(self, v) end; return self end

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
  for v,k in iter.items(it) do table.append(self, v, type(k)~='number' and k or nil) end
	end end; return self end end

-- searchers/selectors
function table.find(...) return swap(iter.find(...)) or nil end

-- find first index for any arg elements
function table:any(...)
  if not is.table(self) then return nil end
  local z = table.hashed(args(...), true)
  return table.find(self, function(i) return z[i] end)
end

function table:all(...)
  if not is.table(self) then return true end
  local z = table.hashed(self, true)
  return (not iter.find(args(...) or table(), function(i) return not z[i] end)) or nil
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

-- consistent with string:null()
function table:nulled() if is.table(self) and type(next(self))~='nil' then return self end end

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

--[[
-- TODO: remove install logic
-- recursively remove mt from internal tables
-- table t installed to self (best for __index)
function table:mtremoved(tt, deep)
  if type(self)~='table' then return self end
  setmetatable(self, nil)
  if type(tt)=='table' then table.update(self, tt) end
  return self
end
--]]

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

local compare = require 'meta.table.compare'
function table.equal(a, b) if type(a)=='table' and type(b)=='table' then
  return compare(a, b, true) else return a==b end end

local function __concat(a, b)
  if type(a)=='table' then
    if is.bulk(b) or type(b)=='table' then
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

function table.tostring(self) return table.concat(self, mt(self).__sep or string.sep) end

function table.map(self, f)    if is.mappable(self) then return iter.collect(iter(self)*f, preserve(self), true) else return nil end end
function table.filter(self, f) if is.mappable(self) then return iter.collect(iter(self)%f, preserve(self), true) else return nil end end
function table.div(self, f)    if is.mappable(self) then return iter(self)/f else return nil end end

return setmetatable(table, {
  __array = true,
  __name= 'table',
  __preserve = true,
  __sep = ",",

  __add = table.append2,
  __call = function(self, ...) return setmetatable(args(...), getmetatable(self)) end,
  __concat = __concat,
  __eq = table.equal,
  __export = function(self) return setmetatable(clone(self, nil, true), nil) end,
  __index = __index,

  __iter = iter.items,
  __div = table.div,
  __mul = table.map,
  __mod = table.filter,

  __tostring = table.tostring,
  __sub = table.delete,
})