require "compat53"
require "meta.gmt"
require "meta.math"
require "meta.string"
require "meta.table"
require "meta.module"

local pkg = ...
local mcache, module, iter =
--  require "meta.no",
  require "meta.mcache",
  require "meta.module",
--  require "meta.is",
--  require "meta.mcache.root",
  require "meta.iter"
local instance = require 'meta.module.instance'
local mtype = require 'meta.module.type'

local save, noop = table.save, function(...) return ... end
local sub = require "meta.module.sub"
--local _ = no
_,_ = root, noop

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
--      if instance[m] then print('  loading loader instance', instance[m], mtype[m]) else print(' skip loading for nil loader instance', mtype[m]) end
      if not mcache.existing.loader(m) then msave=m end
      local mod = module(m)
      if not mod then return pkg:error('nil module', tostring(self), m) end
      if not mod.isdir then return pkg:error('module has no dir', m, mtype(m), 'instance', instance[m]) end

      local l = mcache.loader[mod] or mcache.loader(setmetatable({}, getmetatable(self)), mod.name, sub(mod.name), mod)
      if l and m and msave then
        if not mcache.loader[msave] then
          mcache.loader[msave]=l
          if instance[msave] then mcache.loader[getmetatable(msave)]=l end
        end
      end
      if not mcache.module[l] then mcache.module[l]=mod end
      if mod.isroot then local _ = l ^ true end
      return l
--[[
    else
      local mod = module(self)
      if not mod then return pkg:error('require valid module, got %s' ^  type(mod)) end
      if not mod.modz[mod.short] then return pkg:error('no mod.short: %s' ^ mod.short) end
      mod = (mod/mod.short).loader
      if (not is.callable(mod)) or getmetatable(mod)==getmetatable(self) then return pkg:error('mod is not callable') end
      return mod(...)
--]]
    end
  end,
  __eq=function(a,b) return rawequal(a,b) end,
  __iter = function(self, f) return iter(iter(module(self),function(v,k) return self[k],k end), f) end,
  __index = function(self, key) if type(self)=='table' and type(key)~='nil' then
    if type(key)=='table' and getmetatable(key) then return mcache.loader[key] end
    if type(key)~='string' or key=='' or type(key)=='nil' then return pkg:error('want key (string), got %s' ^ type(key)) end
    local mod = module(self)
    local m = mod..key
    if m then
      print(' load:index', self, key, type(m), type(m.handler), m.node, m.name, m.dirfile)
      if m.d and m.req then
        print(' load:index2', self, key, type(m), type(m.handler))
        return function(h)
          print(' load:__index, return FUNC: m.load TRUE', type(m.handler));
          return m.loader*(h or 'get')
        end
-- or function() end
--      else
--print(' load:index2', self, key, 'load failed')
      end
      return save(self, key, m.get) or self(key)
    else
      print(' load:index FAIL', self, key, mod, m or 'nil')
    end
  end end,
  __div = iter.first,
  __mul = iter.map,
  __mod = iter.filter,
  __name='loader',
  __pairs = function(self) return next, self end,
  __pow = function(self, to)
--    print(' loader:__pow', self, type(to))
    _=module(self)^to; return self end,
  __tostring = function(self) return (module(self) or {}).name or '' end,
  __unm = function(self) return module(self) end,
})