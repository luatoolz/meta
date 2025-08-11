local mt        = require 'meta.gmt'
local iter      = require 'meta.iter'
local is        = require 'meta.is'
local ii        = require 'meta.mt.i'
local indexer   = require 'meta.mt.indexer'
local save      = require 'meta.table.save'
require 'meta.table'

local this = {}
return setmetatable(this,{
  table.index,
  table.interval,
  table.select,
  function(self, k)
    if k==0 then return save(self, 0, {}) end
    if is.table(self) and is.string(k) then
    return getmetatable(self)[k]
  end return nil end,

  -- auto typed items: uncomment to enable
  -- first added item type only allowed
  __newindex=function(self, it, v)
    local i=ii(self, it) or 1
    if type(v)=='nil' then
      self[0][rawget(self,i)]=nil
      table.remove(self,i)
    else
      local item = self[1]
      if ((not item) or is.like(item, v)) and type(self[0][v])=='nil' then
        self[0][v]=true
        rawset(self, i, v)
      end
    end
  end,

  __array=true,
  __preserve=true,
  __sep="\n",
  __add=function(self, it) if is.bulk(it) then return self..it else self[#self+1]=it end; return self end,
  __call=function(self, x, ...)
    local a = is.plain(x) and true or nil
    local base = a and x or {}
    rawset(base,0,{})
    return setmetatable(base,getmetatable(self)) .. iter.tuple((not a) and x or nil, ...)
  end,
  __concat=function(self, it) if it and (is.callable(it) or not is.empty(it)) then
    if (type(self)=='table' and not getmetatable(self)) then iter.collect(iter(it), self, true); return self end
    if is.bulk(it) then for v in iter(it) do _=self+v end else _=self+it end end return self end,
  __eq=table.equal,
  __index = indexer,
  __div=table.div,
  __mul=table.map,
  __mod=table.filter,
  __name='list',
  __pairs=ipairs,
  __sub=function(self, it)
    if it and not is.empty(it) then
      if is.bulk(it) then
        for x in iter(it) do
          if type(x)=='number' then
            local _=self-x
          end
        end
      else if it then
        local i=ii(self, it)
        if type(i)=='number' and i>0 and i<=#self then
          local v = self[i]
          if v then self[0][v]=nil end
          table.remove(self,i)
        end
      end end
    end
    return self
  end,
  __tonumber=function(self) return #self end,
  __tostring=function(self) return table.concat(self*tostring, mt(self).__sep) end,
  __unm=function(self) if #self>0 then self[0][self[#self]]=nil; self[#self]=nil; end; return self end,
})