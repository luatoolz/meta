require "compat53"
local no = require "meta.no"
local cache = require "meta.cache"
local mt = require "meta.mt"
local module = require "meta.module"
local loader = require "meta.loader"
local iter = table.iter
local is = require "meta.is"
return mt({}, {
  __call = function(self, m)
    if type(m) == 'nil' then return nil end
    local wrapper = setmetatable({}, getmetatable(self))
    cache.loader[wrapper]=assert(loader(m))
    local name=tostring(wrapper):null()
    if name then cache.module[wrapper]=cache.module(name) end
    return wrapper
  end,
  __concat = function(self, it)
    if type(it)=='boolean' or type(it)=='table' then
      local keys = type(it)=='table' and it or (cache.loader[self] .. it)
      for k in iter(keys) do
        local _ = self[k]
      end
    end
    return self
  end,
  __iter = function(self) return iter(cache.loader[self] or {}) end,
  __index = function(self, key)
    if type(key)=='nil' then return end
    assert(type(self) == 'table')
    assert((type(key) == 'string' and #key>0) or type(key) == 'nil', ('want key: string or nil, got %s'):format(type(key)))
    local name=tostring(self):null()
    local load=cache.loader[self]
    local mod=cache.module[self]
    if (not mod) and name then
      cache.module[self]=cache.module(name)
      mod=cache.module[self]
    end
    if (not mod) or (not load) then return nil end
    local handler=mod.handler
    if not handler then
      handler=rawget(self, true)
      if handler then
        mod:sethandler(handler)
        rawset(self, true, nil)
      end
    end
    handler=handler or mod.handler
    if not is.callable(handler) then return end
    local rv = no.save(self, key, handler(load[key], key, no.sub(name, key)))
    return rv
  end,
  __mod = function(self, to) if is.callable(to) then return table.filter(self, to) end; return self end,
  __mul = function(self, to) if is.callable(to) then return table.map   (self, to) end; return self end,
  __pairs = function(self) return next, self, nil end,
  __pow = function(self, to)
    if is.callable(to) then
      local name=tostring(self):null()
      if name then module(name):sethandler(to) else rawset(self, true, to) end
    end
    return self
  end,
  __tostring = function(self) return cache.type[self] or '' end,
})
