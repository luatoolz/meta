require "compat53"
local no = require "meta.no"
local cache = require "meta.cache"
local mt = require "meta.mt"
local sub, map = cache.sub, table.map
return mt({}, {
  has = function(self, it) return (self.isdir and type(it)=='string' and self.modz[it]) and true or false end,
  setrecursive=function(self, to) if type(to)=='table' then to=to.torecursive end; if to==false or to then self.torecursive=to or nil end; return self end,
  setpreload=function(self, to) if type(to)=='table' then to=to.torecursive and to.topreload end; if to==false or to then self.topreload=to or nil end; return self end,
  sub = function(self, key) if key then return cache.module(self.name, key):setrecursive(self.torecursive):setpreload(self.torecursive and self.topreload) end end,
  __computed = {
    name = function(self) return sub(self.origin) end,
    path = function(self) return self.file or (self.dir or {})[1] end,
    file = function(self) return cache.file(self.name) end,
    isfile = function(self) return self.file and true or false end,
    isdir = function(self) return #(self.dir or {})>0 and true or false end,
    basename = function(self) return no.basename(self.path) end,
    isroot = function(self) return self.name:match('^[^/.]+$') and true or false end,
    exists = function(self) return self.isfile or self.isdir end,
    files = function(self) return map(self.iterfiles) * no.strip end,
    dirs = function(self) local rv=map(self.iterdirs); return type(next(rv))~='nil' and rv or nil end,
    dir = function(self) local rv=map(self.iterdir); return type(next(rv))~='nil' and rv or nil end,
    mods = function(self) return map(self.itermods) end,
    modz = function(self) return self.mods:tohash() end,
  },
  __computable = {
    ok = function(self) if self.exists then return self end end,
    parent = function(self) return self(no.parent(self.name)) end,
    iterfiles = function(self) return no.files(no.scan(self.name)) end,
    iterdir   = function(self) return no.scan(self.name) end,
    iterdirs  = function(self) return no.dirs(no.scan(self.name)) end,
    itermods  = function(self) return no.modules(self.name) end,
    load = function(self) return self.loaded or no.require(self.name) end,
    loaded = function(self) return cache.loaded[self.name] end,
    loader = function(self) local loader=require("meta.loader"); return loader(self.name) end,
    loading = function(self) return self.load or self.loader end,
    recursive = function(self) self.torecursive=true; return self end,
    notrecursive = function(self) self.torecursive=nil; return self end,
    preload = function(self) self.topreload=true; return self.loader end,
    preloading = function(self) if (self.topreload and not self.preloaded) then self.preloaded=true; return self else return {} end end,
  },
  __call = function(self, o, key)
    if type(o)=='table' then if not key then return cache.module[o] end; o=o.name; end
    if type(o)=='string' and o~='' then if key then o=sub(o, key) end
      return cache.existing.module(o) or cache.module(setmetatable({origin=o}, mt(self)), o) end end,
  __div = function(self, it) return (type(next(self))=='nil' and self(it) or self:sub(it)).loading end,
  __iter = function(self) return no.modules(self.name) end,
  __tostring = function(self) return self.name end,
  __eq = function(self, o) return self.name == o.name end,
  __index = no.computed
}, {"module", sub})
