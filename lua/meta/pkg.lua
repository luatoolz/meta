require 'compat53'
local mt        = require 'meta.gmt'
local iter      = require 'meta.iter'
local table     = require 'meta.table'
local is        = require 'meta.is'
local save      = require 'meta.table.save'
local mcache    = require 'meta.mcache'
local pkgdirs   = require 'meta.module.pkgdirs'
local indexer   = require 'meta.mt.indexer'
require 'meta.module'

local match = {
  dots      = string.matcher('^%.+$'),
  nondot    = string.matcher('[^%.]+'),
  slash     = string.matcher('%/'),
  noslash   = string.matcher('^[^%/]+$'),
}

local gmatch = {
  nondot    = string.gmatcher('[^%.]+'),
  nonslash  = string.gmatcher('[^%/]+'),
}

local key   = {
  dir       = true,
  mod       = false,
  name      = '.',
  parent    = '..',
}

local join = string.joiner('/')
local this = {}
return setmetatable(this, {
  table.index,
  table.interval,
  table.select,
  function(self, k)
    if k==key.mod then return save(self, k, -self) end
    if k==key.dir then return save(self, k, table()) end
    if is.string(k) then
      if match.dots(k) then return rawget(self, k) end
      if match.nondot(k) and match.noslash(k) then
        local mod = -self
        if mod/k then return save(self, k, (mod..k).load) end
        if self/k then return save(self, k, self+k) end
      else
      end
      if match.nondot(k) and match.slash(k) then return self..k end
    end
  end,

  __recursive=false,
  __name='pkg',
  __sep='/',
  __add=function(self, k)
    if is.like(this,self) and is.string(k) and match.noslash(k) then
    if k==key.parent then return #self>0 and self[key.parent] or this end
    if match.nondot(k) and self/k then
      if self[key.dir][k] then return self[key.dir][k] end
      local new = setmetatable(self[{0}], getmetatable(self))
      new[#new+1]=new
      new[key.name]=k
      new[key.parent]=self
      self[key.dir][k]=new
      return new
  end end; return self end,
  __call=function(self, k) return self..k end,
  __concat=function(self, k) if is.like(this,self) and is.string(k) and string(k) then
    local rv=self
    for p in gmatch.nonslash(k) do if rv then rv=rv+p end end
    return rv
  end return self end,
  __eq=rawequal,
  __iter = function(self, to) return iter(iter(self[key.mod].items,function(_,k) return self[k],k end),to) end,
  __index = indexer,
  __div = function(self, k) if is.string(k) and match.nondot(k) and match.noslash(k) then
    return (pkgdirs*join(string(self),k))[1] and true or nil end end,
  __mul = table.map,
  __mod = table.filter,
  __next=function(self, cur)
    local k,v = cur
    repeat k,v = next(self, k)
    until type(k)=='nil' or (type(k)=='string' and not match.dots(k))
    return k,v
  end,
  __pairs = table.mtnext,
  __pow = function(self, to) _=(-self)^to; return self end,
  __tostring = function(self) return table.concat((table()..self[{0}])*key.name, mt(self).__sep) or '' end,
  __unm = function(self) return mcache.module[tostring(self)] end,
})