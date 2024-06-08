require "compat53"

local paths = require "paths"
local no = require "meta.no"
local cache = require "meta.cache"
local mt = require "meta.mt"
local computed = require "meta.computed"

local sub = cache.sub
local unpak = unpack or table.unpack

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
  ok = function(self) if self.exists then return self end end,
  parent = function(self) return cache.module(no.parent(self.name)) end,
  sub = function(self) return function(this, key) if key then local rv=cache.module(sub(self.name, key)); if rv then
    if self.torecursive then rv=rv.recursive end
    return self.topreload and rv.preload or rv
  end end end end,
  files = function(self) local rv = {}; if self.dir then for it in paths.iterfiles(self.dir) do
    if it ~= 'init.lua' then table.insert(rv, no.strip(it)) end end end return rv end,
  dirs = function(self) local rv = {}; if self.dir then
      for it in paths.iterdirs(self.dir) do table.insert(rv, it) end end return rv end,
  load = function(self) return self.loaded or no.require(self.name) end,
  loaded = function(self) return cache.loaded[self.name] end,
  loader = function(self) return cache.loader(self.name) end,
  recursive = function(self) self.torecursive=true; self.files=nil; self.dir=nil; self.submodules=nil; return self end,
  notrecursive = function(self) self.torecursive=nil; self.files=nil; self.dir=nil; self.submodules=nil; return self end,
  submodules = function(self) return self.torecursive and {unpak(self.files), unpak(self.dirs)} or self.files end,
  preload = function(self)
    self.topreload=true
    local l = self.loader
    for _,it in pairs(self.submodules) do _ = l[it] end
    return l
  end,
}, true)

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

return cache("module", no.sub, m)
