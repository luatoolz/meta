require "compat53"
local no, mcache, module, is, root, iter =
  require "meta.no",
  require "meta.mcache",
  require "meta.module",
  require "meta.is",
  require "meta.mcache.root",
  table.iter

return mcache('loader', no.sub) ^ setmetatable({}, {
  __add = function(self, it) if type(it)=='string' then local _ = self[it] end; return self end,
  __call = function(self, ...)
    if self==mcache.new.loader then
      local m, preload, recursive = ...
      if type(m) == 'table' then
        if getmetatable(m)==getmetatable(self) then return m end
        if mcache.existing.loader(m) then return mcache.loader[m] end
      end
      if not m then return nil end
      local msave
      if not mcache.existing.loader(m) then msave=m end
      local mod = module(m) -- call assert to save to logs
      if type(mod) == 'nil' then return nil, 'loader: mod is nil' end
      if not mod.isdir then return nil, 'meta.loader[%s]: has no dir' % mod.name end
      mod:setrecursive(recursive):setpreload(preload)
      local l = mcache.loader[mod] or mcache.loader(setmetatable({}, getmetatable(self)), mod.name, no.sub(mod.name), mod)
      if l and m and msave then
        if not mcache.loader[msave] then
          mcache.loader[msave]=l
          if is.instance(msave) then mcache.loader[getmetatable(msave)]=l end
        end
      end
      if not mcache.module[l] then mcache.module[l]=mod end
      if mod.isroot then local _ = l ^ true end
      return l .. mod.topreload
    else
      local mod = module(self)
      if not mod then return nil, "loader: require valid module, await loader, got %s" %  type(mod) end
      if not mod:has(mod.short) then return nil, 'loader: no mod.short' end
      mod = mod/mod.short
      if (not is.callable(mod)) or getmetatable(mod)==getmetatable(self) then return nil, 'loader: mod is not callable' end
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
  __eq=function(a,b) return rawequal(a,b) end,
  __iter = function(self) local rv = module(self); assert(rv, 'rv is nil'); return iter(rv) end,
  __index = function(self, key)
    if type(key)=='nil' then return end
    assert(type(self) == 'table')
    if type(key)=='table' and getmetatable(key) then return mcache.loader[key] end
    assert((type(key) == 'string' and #key>0) or type(key) == 'nil', 'want key: string or nil, got ' .. type(key))
    local mod=module(self).ok
    if not mod then return self(key) end

    local sub = mod:sub(key)
    if not sub then
      sub=mod:sub(key)
      if not sub.topreload then sub=nil end
    end
    if sub and sub.d.isdir then
      local d = sub.d
      return function(this, handler)
        handler=handler or sub.handler or d.handler
        for it in iter(d) do
          local dsub = d:sub(it)
          if dsub then
            if is.callable(handler) then
              handler(dsub.loading, it, dsub.name)
            else _=dsub.loading end
          end
        end
        return this
      end
    end

    local handler=mod.handler
    if is.callable(handler) then
      local name = no.sub(mod.name, key)
      mod=handler(mod/key, key, name)
    else
      mod=mod/key or root(mod.rel, key)
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
    if type(to)=='string' then _=root+to end
    if type(to)=='boolean' then
      local id=tostring(self):null()
      if id then if to then _=root+id else _=root-id end end
    end
    if is.callable(to) then module(self).link.handler=to end
    return self
  end,
  __sub = function(self, it) rawset(self, it, nil); return self end,
  __tostring = function(self) return module(self).name or '' end,
})