require "compat53"

local cache = require "meta.cache"
local no = require "meta.no"
local path, metas = {}, {}
local module = cache.module

local std = {
--  func = function(o) return type(o)=='function' end,
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
  __call = function(self, ...)
    local o = select(1, ...)
    local p = tostring(self)
    if not p or p=='' then return self ^ o end
    if select('#', ...)==0 then return nil end
    assert(p, 'meta.is object path required, got ' .. type(p))
    local child = no.strip(p, '^.+%/') or ''
    local k=child

-- check standard functions and aliases
    for i,parent in ipairs(metas) do
      if std[k] then return std[k](...) end
      local sub = no.join(parent, 'is', k)
      if module[sub].exists then
        local f = module[sub].load
        if is.callable(f) then
          return f(...)
        end
      end
    end

-- is.net.ip(t)
    local sub = module[p]
    if sub and sub.exists then
      sub=sub.load
      return type(o)==type(sub) and (o==sub or (type(o)=='table' and getmetatable(o) and getmetatable(o)==getmetatable(sub)))
    end

-- is.table.callable(t)
    local parent = no.strip(p, '[^/]*$', '%/?$')
    if parent then
      sub = module[parent]
      if sub and sub.exists then
        sub=sub.load
        if type(sub)=='table' and sub[k] then
          sub=sub[k]
          if type(sub)=='function' then return sub(o) end
          if type(sub)=='table' then
            return type(o)==type(sub) and (o==sub or (type(o)=='table' and getmetatable(o) and getmetatable(o)==getmetatable(sub)))
          end
        end
      end
    end
  end,
  __index = function(self, k)
    if not path[self] then
      if std[k] then return std[k] end
      for i,parent in ipairs(metas) do
        local sub = no.join(parent, 'is', k)
        if module[sub].exists then
          local f = module[sub].load
          if is.callable(f) then
            return f
          end
        end
      end
    end
    local t = setmetatable({}, getmetatable(self))
    path[t]=path[self] and no.join(path[self], k) or k
    return t
  end,
  __pow = function(self, k)
    if type(k)=='string' and #k>0 then
      table.append_unique(metas, k)
    end
    return self
  end,
})

return is('meta')
