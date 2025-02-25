require "compat53"
local pkg = ...
local no, mcache, module, is, root, iter =
  require "meta.no",
  require "meta.mcache",
  require "meta.module",
  require "meta.is",
  require "meta.mcache.root",
  require "meta.iter"
local save, noop = table.save, function(...) return ... end
local sub = require "meta.module.sub"
local _ = no

return mcache('loader', sub) ^ setmetatable({}, {
  __add = function(self, it) if type(it)=='string' then noop(self[it]) end; return self end,
  __call = function(self, ...)
    if self==mcache.new.loader then
      local m = ...
      if type(m) == 'table' then
        if getmetatable(m)==getmetatable(self) then return m end
        if mcache.existing.loader(m) then return mcache.loader[m] end
      end
      if not m then return nil end
      local msave
      if not mcache.existing.loader(m) then msave=m end
      local mod = module(m)
      if not mod then return pkg:error('nil module', tostring(self), m) end
      if not mod.isdir then return pkg:error('module has no dir', m, type(m), 'is.instance', is.instance(m)) end

      local l = mcache.loader[mod] or mcache.loader(setmetatable({}, getmetatable(self)), mod.name, sub(mod.name), mod)
      if l and m and msave then
        if not mcache.loader[msave] then
          mcache.loader[msave]=l
          if is.instance(msave) then mcache.loader[getmetatable(msave)]=l end
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
  __concat = function(self, it)
    if not self then return pkg:error('require valid loader') end
    if type(it)=='table' then it=iter.ivalues(it) end
    if it==true then it=iter(self) end
    if is.callable(it) then for k in it do local _ = self[k] end end
    return self
  end,
  __eq=function(a,b) return rawequal(a,b) end,
  __iter = function(self, f) return iter(iter.it(module(self), function(k) return self[k] end), f) end,
  __index = function(self, key)
    if type(key)=='nil' then return end
    assert(type(self) == 'table')
    if type(key)=='table' and getmetatable(key) then return mcache.loader[key] end
    assert((type(key) == 'string' and #key>0) or type(key) == 'nil', 'want key: string or nil, got ' .. type(key))
    local mod = module(self)
    local m = mod..key
    if m then
      if m.d then
        return m.load and function(h) return h and m.loader*h or m.loader..true end
      end
      return save(self, key, m.get) or self(key)
    end
  end,
--  __mul = iter.map,
--  __mod = iter.filter,
  __mod = function(self, to)
    if is.callable(to) then return iter.filter(iter.pairs(self .. true), to) end
    for k,v in pairs(self) do
      if (getmetatable(v) or {}).__mod and v % to then return k end
    end
    return self
  end,
  __mul = function(self, to)
    assert(type(self)=='table', 'await loader, got: %s'^type(self))
    if is.callable(to) then return iter.map(iter.pairs(self .. true), to) end
    if to==false then return module(self).load end
    if type(to)=='string' then
      return (module(self)/to).load
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
    if is.callable(to) then module(self).opt.handler=to end
    return self
  end,
  __sub = function(self, it) rawset(self, it, nil); return self end,
  __tostring = function(self) return module(self).name or '' end,
  __unm = function(self) return module(self) end,
})