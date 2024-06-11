require "compat53"

local paths = require "paths"
local no = require "meta.no"
local cache = require "meta.cache"
local mt = require "meta.mt"
local computed = require "meta.computed"
local sub = cache.sub

cache("module", sub)
if not cache.normalize.loader then
  require "meta.loader"
end

local m = computed({}, {
  name = function(self) return sub(self.origin) end,
  path = function(self) return self.file or self.dir end,
  file = function(self) return cache.file(self.name) end,
  dir = function(self) return cache.dir(self.name) end,
  isdir = function(self) return self.dir and true or false end,
  basename = function(self) return no.basename(self.path) end,
  isroot = function(self) return self.name:match('^[^/.]+$') and true or false end,
  exists = function(self) return (self.file or self.dir) and true or false end,
  files = function(self) local rv={}; for it in self.iterfiles do if it~='init.lua' then table.insert(rv, no.strip(it)) end end return rv end,
  dirs = function(self) local rv={}; for it in self.iterdirs do table.insert(rv, it) end return rv end,
  submodules = function(self) local rv,seen={},{}
    for it in self.iterfiles do if it~='init.lua' then it=no.strip(it)
      if it and not seen[it] then table.insert(rv, it); seen[it]=true; end end end
    for it in self.iterdirs do
      if no.isfile(no.join(self.dir, it, 'init.lua')) and not seen[it] then table.insert(rv, it); seen[it]=true; end end
    return rv end,
}, {
  ok = function(self) if self.exists then return self end end,
  parent = function(self) return cache.module(no.parent(self.name)) end,
  iterfiles = function(self) return self.dir and paths.iterfiles(self.dir) or function() return nil end end,
  iterdirs = function(self) return self.dir and paths.iterdirs(self.dir) or function() return nil end end,
  load = function(self) return self.loaded or no.require(self.name) end,
  loaded = function(self) return cache.loaded[self.name] end,
  loader = function(self) return cache.loader[self.name] end,
  recursive = function(self) self.torecursive=true; return self end,
  notrecursive = function(self) self.torecursive=nil; return self end,
  preload = function(self) self.topreload=true; return self.loader end,
})

mt(m).setrecursive = function(self, to) self.torecursive = to and true or nil; return self end
mt(m).setpreload = function(self, to) self.topreload = to and true or nil; return self end
mt(m).sub = function(self, key)
  if key then
    local rv=cache.module(sub(self.name, key))
    if rv then
      if self.torecursive then rv=rv.recursive end
      return self.topreload and rv.preload or rv
    end
  end
end

mt(m).__call = function(self, o, key)
  if type(o)=='table' then
    if not key then return getmetatable(o)==mt(self) and o or cache.module[o] end
    o=(o or {}).name
  end
  if type(o)=='string' and o~='' then
    if key then o=sub(o, key) end
    return setmetatable({origin=o}, mt(self))
  end
end
mt(m).__tostring = function(self) return self.name end
mt(m).__eq = function(self, o) return type(self)==type(o) and type(self)=='table' and self.name == o.name end

return cache("module", sub, m)
