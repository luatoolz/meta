require "compat53"

local no = require "meta.no"
local cache = require "meta.cache"
local mt = require "meta.mt"
local module = require "meta.module"
local sub, unsub = cache.sub, cache.unsub

return mt({}, {
  __tostring = function(self) return (module(self) or {}).name or 'meta.loader was empty' end,
--  __pairs = function(self) local mod=module(self); return pairs(table() .. table(mod.files) .. table(mod.dirs)); end,
  __index = function(self, key)
    assert(type(self) == 'table')
    assert((type(key) == 'string' and #key>0) or type(key) == 'nil', 'want key: string or nil, got ' .. type(key))

    local mod=module(self)
    if not mod then
      mod = module(key)
      return mod.load or mod.loader
    end
    mod = mod:sub(key)
    return no.save(self, key, mod.load or mod.loader)
  end,
  __call = function(self, m, topreload, torecursive)
    if type(m) == 'nil' then return nil end
    local mod = module(m)
    if type(mod) == 'nil' then return nil end
    if not mod.isdir then return nil, 'meta.loader(' .. tostring(mod.name) .. ' has no dir' end
    mod:setpreload(topreload):setrecursive(torecursive)

    local l = cache.loader[mod] or cache.loader(setmetatable({}, getmetatable(self)), mod.name, sub(mod.name), unsub(mod.name), mod)
    if not cache.module[l] then cache.module[l]=mod end

    if mod.topreload and not next(l) then
      for _,it in pairs(mod.files) do _ = l[it] end
      for _,it in pairs(mod.dirs) do _ = l[it] end
    end

    return l
  end,
}, {'loader', sub})
