require "compat53"
require "meta.math"
require "meta.string"
require "meta.table"

local pkg       = ...
local module    = require 'meta.module'
local mt        = require "meta.gmt"
local iter      = require 'meta.iter'
local mcache    = require 'meta.mcache'
local instance  = require 'meta.module.instance'
local mtype     = require 'meta.module.type'
local sub       = require 'meta.module.sub'
local save      = require 'meta.table.save'
local indexer   = require 'meta.mt.indexer'

local this      = {}
local cache     = mcache.loader ^ {
  normalize     = sub,
}
return cache ^ setmetatable(this, {
  table.index,
  table.interval,
  table.select,
  function(self, key) if type(self)=='table' and type(key)~='nil' then
    if type(key)=='table' and getmetatable(key) then return cache[key] end
    if type(key)~='string' or key=='' or type(key)=='nil' then return pkg:error('want key (string), got %s' ^ type(key)) end
    local m = module(self,key)
    if m then if m.d and m.d.req then
      return function(h) if type(h)=='table' and rawequal(mt(h),mt(self)) then h=nil end; return m.d.loader*(h or 'get') end end
      return save(self, key, m.get) or self(key) end end end,

  __call = function(self, ...)
    if self==this then
      local m = ...
      if type(m) == 'table' then
        if getmetatable(m)==getmetatable(self) then return m end
        if cache/m then return cache[m] end
        if instance[m] then m=instance[m] end end
      if not m then return pkg:error('nil argument') end
      local msave
      if not mcache.existing.loader(m) then msave=m end
      local mod = module(m)
      if not mod then return pkg:error('nil module', self, m) end
      if not mod.isdir then return pkg:error('module has no dir', m, mtype(m), instance[m]) end

      local l = cache[mod] or cache(setmetatable({}, getmetatable(self)), mod.name, mod)
      if l and m and msave then
        if not cache[msave] then
          cache[msave]=l
          if instance[msave] then cache[getmetatable(msave)]=l end end end
      if type(l)~='nil' then mcache.module[l]=mod end
      if mod.isroot then local _ = l ^ true end
      return l end end,

  __eq=rawequal,
  __iter = function(self, to) return iter(iter(module(self).items,function(_,k) return self[k],k end),to) end,
  __index = indexer,
  __div = table.div,
  __mul = table.map,
  __mod = table.filter,
  __name='loader',
  __recursive=false,
  __pairs = function(self) return next, self end,
  __pow = function(self, to) _=(-self)^to; return self end,
  __tostring = function(self) return tostring(-self) end,
  __unm = function(self) return module(self) end,
})