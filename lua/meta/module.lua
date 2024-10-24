require "compat53"
local no = require "meta.no"
local cache = require "meta.cache"
local match = require "meta.match"
local loader
local default = {
  preload = false,
  recursive = true,
}
local is = {
  callable = function(o) return (type(o)=='function' or (type(o)=='table' and type((getmetatable(o) or {}).__call) == 'function')) end,
}
local root=cache.root
return cache("module", cache.sub) ^ setmetatable({}, {
  has = function(self, it) return (self.isdir and type(it)=='string' and self.modz[it]) and true or false end,
  setrecursive=function(self, to)
    if type(to)=='table' then to=to.torecursive end
    if type(to)=='boolean' then self.torecursive=to end
    if type(to)=='nil' and type(self.torecursive)=='nil' then self.torecursive=default.recursive end
    return self
  end,
  setpreload=function(self, to)
    if type(to)=='table' then to=to.torecursive and to.topreload end
    if type(to)=='boolean' then self.topreload=to end
    if type(to)=='nil' and type(self.topreload)=='nil' then self.topreload=default.preload end
    return self
  end,
  sub = function(self, key) if key then return cache.module(self.name, key):setrecursive(self.torecursive):setpreload(self.torecursive and self.topreload) end end,
  pkg = function(self, it) if type(it)=='table' then it=cache.type[it] or cache.type[getmetatable(it)] end
    if type(it)~='string' or it:match('^%s*$') then return end
    return self(self(it).base)
  end,
  __computed = {
    id        = function(self) return match.id(self.node) end,
    name      = function(self) return cache.sub(self.origin) end,
    node      = function(self) return cache.sub(self.origin) end,
    root      = function(self) return root[self.node] and match.root(self.node) end,
    path      = function(self) return self.file or self.dir end,
    dir       = function(self) return self.pkgdirs[1] end,
    file      = function(self) return cache.file[self.name] end,
    isroot    = function(self) return self.name==self.root end,
    isfile    = function(self) return self.file~=nil end,
    isdir     = function(self) return self.dir~=nil end,
    base      = function(self) return self.based and self.name:match("^(.*)[./][^./]*$") or self.name end,
    virtual   = function(self) return ((not self.isfile) and (not self.isdir)) end,
    exists    = function(self) return self.isfile or self.isdir end,
    link      = function(self) return {} end, -- handler, storage
  },
  __computable = {
    inamed    = function(self) return cache.sub(self.origin) end,

    modz      = function(self) return self.mods:tohash() end,

    files     = function(self) return cache.files[self.name] end,
    dirs      = function(self) return cache.dirs[self.name] end,
    mods      = function(self) return cache.modules[self.name] end,
    pkgdirs   = function(self) return cache.pkgdirz[self.name] end,

    ok        = function(self) if self.exists then return self end end,
    d         = function(self) return self(self.name .. '.d') end,
    parent    = function(self) return self(no.parent(self.name)) end,
    empty     = function(self) return type(next(self))=='nil' end,
    based     = function(self) return (self.virtual or self.luafile) and true or false end,
    luafile   = function(self) return self.file and self.file:gsub('.*init%.lua$', ''):match('.*%.lua') end,
    initlua   = function(self) return self.file:match('^.+init%.lua$') end,
    hasinit   = function(self) return self.file:match('.*init%.lua$') and true or false end,

    req       = function(self) return no.require(self.name) end,
    load      = function(self) return self.exists and (self.loaded or self.req) or nil end,
    loaded    = function(self) return cache.loaded[self.name] end,
    loader    = function(self) loader=loader or require("meta.loader"); return loader(self.name) end,
    loading   = function(self) return self.file and self.load or self.loader end,

    recursive = function(self) self.torecursive=true; return self end,
    notrecursive = function(self) self.torecursive=nil; return self end,
    preload   = function(self) self.topreload=true; return self.loader end,
    preloading = function(self) if (self.topreload and not self.preloaded) then self.preloaded=true; return self else return {} end end,
    handler   = function(self) return self.link.handler or (self.d.isdir and self.luafile and self.load) end,
    basename  = function(self) return no.basename(self.path) end,
  },
  __call = function(self, o, key)
    if type(o)=='table' then if not key then return cache.module[o] end; o=o.name; end
    if type(o)=='string' and o~='' then if key then o=cache.sub(o, key) end
      return cache.existing.module(o) or cache.module(setmetatable({origin=o}, getmetatable(self)), o) end end,
  __div = function(self, it) return (self.empty and self(it) or self:sub(it)).loading end,
  __eq = function(self, o) return self.name == o.name end,
  __index = no.computed,
  __iter = function(self) return table.ivalues(self.mods) end,
  __mod = function(self, to) return end,
  __mul = function(self, to) if to==false then return self.load end end,
  __name='module',
  __pow = function(self, to)
    if type(to)=='string' then _=cache.root+to end
    if type(to)=='boolean' then
      local id=tostring(self):null()
      if id then if to then _=cache.root+id else _=cache.root-id end end
    end
    if is.callable(to) then self.link.handler=to end
    return self end,
  __tostring = function(self) return self.name end,
})