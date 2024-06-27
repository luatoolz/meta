require "compat53"

local cache = require "meta.cache"
local module = cache.module
local path, metas = {}, {}

local is

local function join(...) return table.concat({...}, '/') end
local function ending(s) if type(s)=='string' then return (s:match('[^/]+$') or '') end end

is = setmetatable({
  callable = function(o)
    return type(o)=='function' or (type(o)=='table' and type((getmetatable(o) or {}).__call)=='function') end,
  cache = function(o) return type(o)=='table' and (getmetatable(o) == getmetatable(cache.any)) end,
  loader = function(o) if not cache.normalize.loader then require "meta.loader" end
    return type(o)=='table' and (getmetatable(o) == getmetatable(cache.new.loader)) end,
  module = function(o) if not cache.normalize.module then require "meta.module" end
    return type(o)=='table' and (getmetatable(o) == getmetatable(cache.new.module)) end,
  iterable = function(x) return type(x)=='table' or type((getmetatable(x or {}) or {}).__pairs)=='function' end,
}, {
  __tostring = function(self) return path[self] or '' end,
  __call = function(self, ...)
    local o = select(1, ...)
    local p = tostring(self)
    if not p or p=='' then return self ^ o end
    if select('#', ...)==0 then return nil end
    assert(p, 'meta.is object path required, got ' .. type(p))
    local child = ending(p)
    local k=child

    for i,parent in ipairs(metas) do
      local sub = join(parent, 'is', k)
      if cache.normalize.module then
        if module[sub].exists then
          local f = module[sub].load
          if is.callable(f) then
            return f(...)
          end
        end
      else
        local f = require(sub)
        if is.callable(f) then return f(...) end
      end
    end

-- is.net.ip(t)
    assert(cache.new.module and cache.normalize.module, 'meta.module should be loaded')
    local sub = module[p]
    if sub and sub.exists then
      sub=sub.load
      return type(o)==type(sub) and (o==sub or (type(o)=='table' and getmetatable(o) and getmetatable(o)==getmetatable(sub)))
    end

-- is.table.callable(t)
--    local parent = no.strip(p, '[^/]*$', '%/?$')
    local parent = p:gsub('[^/]*$', '', 1):gsub('%/?$', '', 1)
    if parent=='' then parent=nil end

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
      for i,parent in ipairs(metas) do
        local sub = join(parent, 'is', k)
        if module[sub].exists then
          local f = module[sub].load
          if is.callable(f) then
            return f
          end
        end
      end
    end
    local t = setmetatable({}, getmetatable(self))
    path[t]=path[self] and join(path[self], k) or k
    return t
  end,
  __pow = function(self, k)
    if type(k)=='string' and #k>0 then
      -- keep 2 records for each searchable module name: ordered + mapped
      if not metas[k] then
        table.insert(metas, k)
        metas[k]=true
      end
    end
    return self
  end,
})

return is('meta')
