require "compat53"

local cache = require "meta.cache"
local no = require "meta.no"
local sub, unsub = cache.sub, cache.unsub

cache('loader', no.sub)
if not cache.normalize.module then no.require "meta.module" end

local loader = {}
setmetatable(loader, {
  __tostring = function(self)
    local rv = {}
    for k,_ in pairs(self) do table.insert(rv, k) end
    return string.format('meta.loader[%s]={ %s }', cache.module(self).name, table.concat(rv, ' '))
  end,
  __index = function(self, key)
    assert(type(self) == 'table')
    assert(getmetatable(self) == getmetatable(loader))
    assert(self ~= loader)
    assert(type(key) == 'string' or type(key) == 'nil', 'want key: string or nil, got ' .. type(key))

    local mod = cache.module[self]
    if mod and key then mod = mod:sub(key) end
    local rv = mod.load or mod.loader
    rawset(self, key, rv)
    return rv
  end,
  __call = function(self, m)
    if type(m) == 'nil' then return nil end
    local mod = cache.module[m]
    if type(mod) == 'nil' then return nil end
    if not mod.isdir then return nil, 'meta.loader(' .. tostring(mod.name) .. ' is not dir' end

    local l = cache.loader(setmetatable({}, getmetatable(self)), mod.name, sub(mod.name), unsub(mod.name), mod)
    cache.module[l] = mod

    return l
  end,
})

return cache('loader', no.sub, loader)
