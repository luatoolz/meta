require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
require "meta.table"
--require 'meta.module'

local pkg = ...
local mcache, module, iter =
  require "meta.mcache",
  require "meta.module",
  require "meta.iter"

local instance = require 'meta.module.instance'
local mtype    = require 'meta.module.type'
local sub      = require 'meta.module.sub'
local save     = require 'meta.table.save'

return mcache('loader', sub) ^ setmetatable({}, {
  __call = function(self, ...)
    if self==mcache.new.loader then
      local m = ...
      if type(m) == 'table' then
        if getmetatable(m)==getmetatable(self) then return m end
        if mcache.existing.loader(m) then return mcache.loader[m] end
        if instance[m] then m=instance[m] end
      end
      if not m then return pkg:error('nil argument') end
      local msave
      if not mcache.existing.loader(m) then msave=m end
      local mod = module(m)
      if not mod then return pkg:error('nil module', tostring(self), m) end
      if not mod.isdir then
        return pkg:error('module has no dir', m, mtype(m), 'instance', instance[m]) end

      local l = mcache.loader[mod] or mcache.loader(setmetatable({}, getmetatable(self)), mod.name, sub(mod.name), mod)
      if l and m and msave then
        if not mcache.loader[msave] then
          mcache.loader[msave]=l
          if instance[msave] then mcache.loader[getmetatable(msave)]=l end
        end
      end
      if type(l)~='nil' then mcache.module[l]=mod end
--      if not mcache.module/l then mcache.module[l]=mod end
      if mod.isroot then local _ = l ^ true end
      return l
    end
  end,
  __eq=function(a,b) return rawequal(a,b) end,
  __iter = function(self, to) return iter(iter(module(self).items,function(_,k) return self[k],k end),to) end,
  __index = function(self, key) if type(self)=='table' and type(key)~='nil' then
    if type(key)=='table' and getmetatable(key) then return mcache.loader[key] end
    if type(key)~='string' or key=='' or type(key)=='nil' then return pkg:error('want key (string), got %s' ^ type(key)) end
    local m = module(self,key)
    if m then if m.d and m.d.req then local ldr=m.d.loader; return function(h) return ldr*(h or 'get') end end
      return save(self, key, m.get) or self(key) end end end,
  __div = table.div,
  __mul = table.map,
  __mod = table.filter,
  __name='loader',
  __pairs = function(self) return next, self end,
  __pow = function(self, to) _=module(self)^to; return self end,
  __tostring = function(self) return (module(self) or {}).name or '' end,
  __unm = function(self) return module(self) end,
})