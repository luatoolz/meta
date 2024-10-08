require "compat53"
local no = require "meta.no"
local cache = require "meta.cache"
local mt = require "meta.mt"
local module = require "meta.module"
local sub, unsub = cache.sub, cache.unsub
local iter = table.iter

local is = {
  callable=function(to) return type(to)=='function' or ((type(to)=='table' or type(to)=='userdata') and type((getmetatable(to) or {}).__call)=='function') end,
}

return cache('loader', sub) ^ mt({}, {
  __add = function(self, it) if type(it)=='string' then local _ = self[it] end; return self end,
  __call = function(self, m, topreload, torecursive)
    if type(m) == 'nil' then return nil end
    if type(m)=='table' and getmetatable(m)==getmetatable(self) then return m end
    local mod = module(m)
    if type(mod) == 'nil' then return nil end
    if not mod.isdir then return nil, 'meta.loader(' .. tostring(mod.name) .. ' has no dir' end
    mod:setrecursive(torecursive):setpreload(topreload)
    local l = cache.loader[mod] or cache.loader(setmetatable({}, getmetatable(self)), mod.name, sub(mod.name), unsub(mod.name), mod)
    if not cache.module[l] then cache.module[l]=mod end
    return l .. mod.topreload
  end,
  __concat = function(self, mod)
    assert(self, 'require valid loader')
    if mod==true then mod=iter(self) end
    if type(mod)=='table' then mod=table.ivalues(mod) end
    if type(mod)=='function' then for it in mod do local _ = self[it] end end
    return self
  end,
  __iter = function(self) local rv = module(self); assert(rv, 'rv is nil'); return iter(rv) end,
  __index = function(self, key)
    if type(key)=='nil' then return end
    assert(type(self) == 'table')
    assert((type(key) == 'string' and #key>0) or type(key) == 'nil', 'want key: string or nil, got ' .. type(key))
    local mod=module(self)
    if not mod then return self(key) end

    local d = mod:sub(key .. '.d')
    if not d then
      d=mod:sub(key)
      if not d.topreload then d=nil end
    end
    if d and d.isdir then
      return function(this, handler2)
        local handler = d.link.handler or handler2 or function(...) return end
        for it in d.itermods do
          local dsub = d:sub(it)
          handler(dsub.loading, it, dsub.name)
        end
        return this
      end
    end

    local handler=mod.link.handler
    if is.callable(handler) then
      local subname = no.sub(mod.name, key)
      local new=handler(mod/key, key, no.sub(mod.name, key))
      mod=no.cache(subname, new)
      cache.instance[mod]=mod
    else
      mod=mod/key
    end
    return no.save(self, key, mod)
  end,
  __mod = function(self, to)
    if is.callable(to) then return table.filter(self .. true, to) end
    for k,v in pairs(self) do
      if (getmetatable(v) or {}).__mod and v % to then return k end
    end
    return self
  end,
  __mul = function(self, to) if is.callable(to) then return table.map   (self .. true, to) end; return self end,
  __pairs = function(self) return next, self, nil end,
  __pow = function(self, to)
    if type(to)=='string' then no.parse(to) end
    if type(to)=='boolean' then
      local id=tostring(self):null()
      if id then if to then _=cache.roots+id else _=cache.roots-id end end
    end
    if is.callable(to) then module(self).link.handler=to end
    return self
  end,
  __sub = function(self, it) rawset(self, it, nil); return self end,
  __tostring = function(self) return (module(self) or {}).name or '' end,
})
