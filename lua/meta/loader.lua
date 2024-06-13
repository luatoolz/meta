require "compat53"

local cache = require "meta.cache"
local no = require "meta.no"
local sub, unsub, module = cache.sub, cache.unsub, cache.module

cache('loader', sub)
if not cache.normalize.module then no.require "meta.module" end

local loader = {}
setmetatable(loader, {
  __tostring = function(self)
    return (module[self] or {}).name or 'meta.loader was empty'
  end,
  __index = function(self, key)
    assert(type(self) == 'table')
    assert(getmetatable(self) == getmetatable(loader))
    assert((type(key) == 'string' and #key>0) or type(key) == 'nil', 'want key: string or nil, got ' .. type(key))

    local mod
    if self==loader then
      mod = module[key]
      return mod.load or mod.loader
    end
    mod = module[self]:sub(key)
    return no.save(self, key, mod.load or mod.loader)
  end,
  __call = function(self, m, topreload, torecursive)
    if type(m) == 'nil' then return nil end
    local mod = module[m]
    if type(mod) == 'nil' then return nil end
    if not mod.isdir then return nil, 'meta.loader(' .. tostring(mod.name) .. ' has no dir' end
    mod:setpreload(topreload):setrecursive(torecursive)

    local l = cache.loader[mod]
    if not l then
      l = setmetatable({}, getmetatable(self))
      cache.loader(l, mod.name, sub(mod.name), unsub(mod.name), mod)
      module[l] = mod
    end

    if mod.topreload then
      for _,it in pairs(mod.files) do _ = l[it] end
      for _,it in pairs(mod.dirs) do _ = l[it] end
    end

    return l
  end,
})

cache('loader', sub, loader)
return loader
