require "compat53"
local pkg = ...
local no = require "meta.no"
local cache = require "meta.cache"
local mt = require "meta.mt"
local module = require "meta.module"
local iter = table.iter
local root = require "meta.root"
local _ = root

local is = {
  callable = function(to) return type(to)=='function' or ((type(to)=='table' or type(to)=='userdata') and type((getmetatable(to) or {}).__call)=='function') end,
}

return cache('loader', cache.sub) ^ mt({}, {
  __add = function(self, it) if type(it)=='string' then local _ = self[it] end; return self end,
  __call = function(self, ...)
    if self==cache.new.loader then
      local m, topreload, torecursive = ...
      if type(m) == 'nil' then return nil end
      if type(m) == 'table' then
        if getmetatable(m)==getmetatable(self) then return m end
        return cache.existing.loader[m]
      end
      local mod = module(m)
      if type(mod) == 'nil' then return nil end
      if not mod.isdir then return nil, 'meta.loader(' .. tostring(mod.name) .. ' has no dir' end
      mod:setrecursive(torecursive):setpreload(topreload)
      local l = cache.loader[mod] or cache.loader(setmetatable({}, getmetatable(self)), mod.name, cache.sub(mod.name), mod) --cache.unsub(mod.name), mod)
      if not cache.module[l] then cache.module[l]=mod end
      if mod.isroot then local _ = l ^ true end
      return l .. mod.topreload
    else
      local mod = module(self)
      assert(mod, ("loader: require valid module, await %s, got %s: %s"):format('loader', type(mod), table.concat({...}, " - ")))
      if not mod:has(mod.id) then return end
      mod = mod/mod.id
      if (not is.callable(mod)) or getmetatable(mod)==getmetatable(self) then return end
      return mod(...)
    end
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
    if type(key)=='table' and getmetatable(key) then return cache.loader[key] end
    assert((type(key) == 'string' and #key>0) or type(key) == 'nil', 'want key: string or nil, got ' .. type(key))
    local mod=module(self)
    if not mod then return self(key) end

    local sub = mod:sub(key)
    if not sub then
      sub=mod:sub(key)
      if not sub.topreload then sub=nil end
    end
    if sub and sub.d.isdir then
      local d = sub.d
--      local hf = mod * key
--      local hf = sub*false
      return function(this, handler)
--        if not sub.link.handler and sub.handler then end
        handler=handler or sub.handler
        for it in d.itermods do
          local dsub = d:sub(it)
          if dsub and is.callable(handler) then
            handler(dsub.loading, it, dsub.name)
          end
        end
        return this
      end
    end

    local handler=mod.handler
    if is.callable(handler) then
      local name = no.sub(mod.name, key)
      mod=handler(mod/key, key, name)
--      cache.loaded[name]=mod
    else
      mod=mod/key
    end
    return table.save(self, key, mod)
  end,
  __mod = function(self, to)
    if is.callable(to) then return table.filter(self .. true, to) end
    for k,v in pairs(self) do
      if (getmetatable(v) or {}).__mod and v % to then return k end
    end
    return self
  end,
  __mul = function(self, to)
    if is.callable(to) then return table.map(self .. true, to) end
    if to==false then return module(self).load end
    if type(to)=='string' then
      return module(self):sub(to).load
    end
    return self
  end,
  __name='loader',
  __pairs = function(self) return next, self, nil end,
  __pow = function(self, to)
    if type(to)=='string' then _=cache.root+to end
    if type(to)=='boolean' then
      local id=tostring(self):null()
      if id then if to then _=cache.root+id else _=cache.root-id end end
    end
    if is.callable(to) then module(self).link.handler=to end
    return self
  end,
  __sub = function(self, it) rawset(self, it, nil); return self end,
  __tostring = function(self) return (module(self) or {}).name or pkg or '' end,
})