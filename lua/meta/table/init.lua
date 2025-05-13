require "compat53"
require "meta.gmt"
require 'meta.math'
require 'meta.string'

local iter = require 'meta.iter'
local meta = require 'meta.lazy'
local fn, pkg, mmt = meta({'fn', 'table', 'mt'})

local index, preserve, maxi = mmt.i, pkg.preserve, pkg.maxi
local mt, args, swap = table.unpack(fn[{'mt','args','swap'}])

local is = require 'meta.is'

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
function table:indexer()   return type(self)=='table' and function(...) return self[...] end or nil end
function table:getter()    return function(k)   return self[k], k               end end
function table:appender()  return function(...) return table.append(self, ...)  end end
function table:concatter() return function(x)   return self..x                  end end
function table:saver()     return function(...) return table.save(self, ...)    end end
function table:uappender() return function(...) return table.append_unique(self, ...) end end
function table:deleter()   return function(...) return table.delete(self, ...)  end end
function table:updater()   return function(...) return table.update(self, ...)  end end

-- uses iter arguments order (v,k)
table.save     = require 'meta.table.save'
table.append   = require 'meta.table.append'
table.index    = require 'meta.table.index'
table.interval = require 'meta.table.interval'
table.select   = require 'meta.table.select'
table.sub      = require 'meta.table.sub'
table.clone    = require 'meta.table.clone'

function table:append2(v, k) if is.table(self) then if type(v)~='nil' then
  if type(k)~='nil' and type(k)~='number' then self[k]=v else
    if type(k)=='number' and k<=#self+1 then
      if k<1 then k=1 end table.insert(self, k, v)
    else table.insert(self, #self+1, v)
    end end end end return self end

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

local compare = require 'meta.table.compare'

function table.equal(a, b) if is.table(a) and is.table(b) then return compare(a, b, true) else return a==b end end
function table.merge(a, b) if is.table(a) then return (is.bulk(b) or is.table(b)) and iter.collect(iter(b), a, true) or a end return nil end
--function table.tostring(self) return table.concat(self, mt(self).__sep or string.sep) end
--function table.tostring(self) return (mt(self).__sep or string.sep):join(self[0], self) or '' end

function table.map(self, f)    if is.mappable(self) then return iter.collect(iter(self)*f, preserve(self), true) else return nil end end
function table.filter(self, f) if is.mappable(self) then return iter.collect(iter(self)%f, preserve(self), true) else return nil end end
function table.div(self, f)    if is.mappable(self) then return iter(self)/f else return nil end end

return setmetatable(table, {
  table.index,
  table.interval,
  table.select,

  __array     = true,
  __name      = 'table',
  __preserve  = true,
  __sep       = ',',

  __add       = table.append2,
  __call      = function(self, ...) return setmetatable(args(...), getmetatable(self)) end,
  __concat    = table.merge,
  __eq        = table.equal,
  __export    = function(self) return setmetatable(table.clone(self, nil, true), nil) end,
  __index     = mmt.indexer,

  __iter      = iter.items,
  __div       = table.div,
  __mul       = table.map,
  __mod       = table.filter,

  __tostring  = mmt.tostring,
  __sub       = table.delete,
})