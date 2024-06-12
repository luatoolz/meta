require "compat53"

local cache = require "meta.cache"
local no = require "meta.no"
local path = {}
local module = cache.module

local std = {
  func = function(o) return type(o)=='function' end,
  callable = function(o) return type(o)=='function' or (type(o)=='table' and type((getmetatable(o) or {}).__call)=='function') end,
  cache = function(o) return type(o)=='table' and (getmetatable(o) == getmetatable(cache.any)) end,
  loader = function(o) if not cache.normalize.loader then no.require "meta.loader" end
    return type(o)=='table' and (getmetatable(o) == getmetatable(cache.new.loader)) end,
  module = function(o) if not cache.normalize.module then no.require "meta.module" end
    return type(o)=='table' and (getmetatable(o) == getmetatable(cache.new.module)) end
}

local is
is = setmetatable({}, {
  __tostring = function(self) return path[self] or '' end,
  __call = function(self, o)
    if type(o)=='nil' then return nil end
    local p = tostring(self)
    assert(p)
    local parent = no.strip(p, '[^/]*$', '%/?$')
    local child = no.strip(p, '^.+%/')
    local k=child

-- check standard functions and aliases
    if parent:match('^[^/.]+$') then -- isroot
      if std[k] then return std[k](o) end
      local sub = no.join(parent, 'is', k)
      if module[sub].exists then
        local f = module[sub].load
        if type(f)=='function' then
          return f(o)
        end
      end
    end

-- is.net.ip(t)
    local sub = module[p]
    if sub.exists then
      sub=sub.load
      return type(o)==type(sub) and (o==sub or (type(o)=='table' and getmetatable(o) and getmetatable(o)==getmetatable(sub)))
--      if is.cache
--      if is.loader
--      if is.module
    end

-- is.table.callable(t)
    sub = module[parent]
    if sub.exists then
      sub=sub.load
      if type(sub)=='table' and sub[k] then
        sub=sub[k]
        if type(sub)=='function' then return sub(o) end
        if type(sub)=='table' then
          return type(o)==type(sub) and (o==sub or (type(o)=='table' and getmetatable(o) and getmetatable(o)==getmetatable(sub)))
        end
      end
    end
  end,
  __index = function(self, k)
    if not path[self] and std[k] then return std[k] end
    local t = setmetatable({}, getmetatable(self))
    path[t]=path[self] and no.join(path[self], k) or k
    return t
  end,
})

return is
