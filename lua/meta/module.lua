require "compat53"

local paths = require "paths"
local no = require "meta.no"
local cache = require "meta.cache"
local mt = require "meta.mt"
local sub = cache.sub

return mt({}, {
  hasmodule = function(self, it) return (self.dir and type(it)=='string') and no.ismodule(self.dir, it) or false end,
  setrecursive=function(self, to) if type(to)=='table' then to=to.torecursive end; if to==false or to then self.torecursive=to or nil end; return self end,
  setpreload=function(self, to) if type(to)=='table' then to=to.torecursive and to.topreload end; if to==false or to then self.topreload=to or nil end; return self end,
  sub = function(self, key) if key then return cache.module(self.name, key):setrecursive(self.torecursive):setpreload(self.torecursive and self.topreload) end end,
  __computed = {
    name = function(self) return sub(self.origin) end,
    path = function(self) return self.file or self.dir end,
    file = function(self) return cache.file(self.name) end,
    dir = function(self) return cache.dir(self.name) end,
    isdir = function(self) return self.dir and true or false end,
    basename = function(self) return no.basename(self.path) end,
    isroot = function(self) return self.name:match('^[^/.]+$') and true or false end,
    exists = function(self) return (self.file or self.dir) and true or false end,
    files = function(self) return table.map(self.iterfiles, no.strip) end,
    dirs = function(self) return table.map(self.iterdirs) end,
    submodules = function(self) local rv,seen={},{}
      for it in self.iterfiles do if it~='init.lua' then it=no.strip(it)
        if it and not seen[it] then table.insert(rv, it); seen[it]=true; end end end
      for it in self.iterdirs do
        if no.isfile(no.join(self.dir, it, 'init.lua')) and not seen[it] then table.insert(rv, it); seen[it]=true; end end
      return rv end,
  },
  __computable = {
    ok = function(self) if self.exists then return self end end,
    parent = function(self) return self(no.parent(self.name)) end,
    iterfiles = function(self) return self.dir and paths.iterfiles(self.dir) or function() return nil end end,
    iterdirs = function(self) return self.dir and paths.iterdirs(self.dir) or function() return nil end end,
    load = function(self) return self.loaded or no.require(self.name) end,
    loaded = function(self) return cache.loaded[self.name] end,
    loader = function(self) local loader=require("meta.loader"); return loader(self.name) end,
    recursive = function(self) self.torecursive=true; return self end,
    notrecursive = function(self) self.torecursive=nil; return self end,
    preload = function(self) self.topreload=true; return self.loader end,
  },
  __call = function(self, o, key)
    if type(o)=='table' then
      if not key then return cache.module[o] end
      o=o.name
    end
    if type(o)=='string' and o~='' then
      if key then o=sub(o, key) end
      return cache.existing.module(o) or cache.module(setmetatable({origin=o}, mt(self)), o)
    end
  end,
  __tostring = function(self) return self.name end,
  __eq = function(self, o) return type(self)==type(o) and type(self)=='table' and getmetatable(o) and getmetatable(self)==getmetatable(o) and self.name == o.name end,
  __index = no.computed
}, {"module", sub})
