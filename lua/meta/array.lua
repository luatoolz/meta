local mt        = require 'meta.gmt'
local iter      = require 'meta.iter'
local is        = require 'meta.is'
local ii        = require 'meta.mt.i'
local indexer   = require 'meta.mt.indexer'
require 'meta.table'

local this = {}
return setmetatable(this,{
  table.index,
  table.interval,
  table.select,
  function(self, k) if is.table(self) and is.string(k) then
    return getmetatable(self)[k]
  end return nil end,

  flatten=function(...)
    local rv=this()
    for v in iter.tuple(...) do table.flattened(v,rv) end
    return rv
  end,

  -- auto typed items: uncomment to enable
  -- first added item type only allowed
  __newindex=function(self, it, v)
    local i=ii(self, it) or 1
    if type(v)=='nil' then return rawset(self, i, v) end
    local item = self[1]
    if (not item) or is.like(item, v) then rawset(self, i, v) end
  end,

  __array=true,
  __preserve=true,
  __sep="\n",
  __add=function(self, it) if is.bulk(it) then return self..it else self[#self+1]=it end; return self end,
  __call=function(self, x, ...)
    local a = is.plain(x) and true or nil
    return setmetatable(a and x or {},getmetatable(self))..iter.tuple((not a) and x or nil, ...) end,
  __concat=function(self, it) if it and (is.callable(it) or not is.empty(it)) then
    if (type(self)=='table' and not getmetatable(self)) then iter.collect(iter(it), self, true); return self end
    if is.bulk(it) then for v in iter(it) do _=self+v end else _=self+it end end return self end,
  __eq=table.equal,
  __eq1=function(a, b)
    if is.like(a,b) and #a==#b then
      for i=1,#a do if a[i]~=b[i] then return false end; end;
      return true
    end
    return false
  end,
  __index = indexer,
  __div=table.div,
  __mul=table.map,
  __mod=table.filter,
  __name='array',
  __pairs=ipairs,
  __sub=function(self, it)
    if it and not is.empty(it) then
      if is.bulk(it) then
        for x in iter(it) do local _=self-x end
      else if it then
        local i=ii(self, it)
        if i>0 then
          if i>#self then i=nil end
          table.remove(self, i)
        end
      end end
    end
    return self
  end,
  __tonumber=function(self) return #self end,
  __tostring=function(self) return table.concat(self*tostring, mt(self).__sep) end,
  __unm=function(self) if #self>0 then table.remove(self) end; return self end,
})