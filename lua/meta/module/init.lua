local pkg = ...
local checker = require "meta.checker"
local call = require 'meta.call'
local mcache = require "meta.mcache"
local iter = require 'meta.iter'
local seen = require 'meta.seen'
local meta = require 'meta.lazy'
local is, fn, md = meta({'is', 'fn', 'module'})

local _,_ = fn[{'n', 'noop','k','kk','v','vv','swap'}],
            is[{'callable','toindex','pkgloaded','like'}]

local computed, setcomputed =
  require "meta.mt.computed",
  require "meta.mt.setcomputed"

local function fixer(x) return x and x:gsub('([^%.][^d])$','%1.d') or nil end
local loader

local join = string.joiner('/')
local n = fn.n
local get = {
  pkgloadtype = function(x) return type(package.loaded[x]) end,
  noinit = function(v,k) if k~='init' then return v,k end end,
  init = function(v,k) if k=='init' then return v,k end end,
}
local has = {
  value = require 'meta.is.has.value',
}

local sub, options, pkgdir, instance, mtype =
  table.unpack(md[{'sub','options','pkgdir','instance','type','chain','searcher'}])

local complex = checker({["userdata"]=true,["table"]=true,["function"]=true,["CFunction"]=true,["string"]=true,}, type)

local this, cache
cache = mcache.module ^ {
  normalize = sub,
  div       = function(self, to)
    return self[to]
  end,
}
this = cache ^ setmetatable({
  pkgdirs     = (table()..package.path:gmatch('[^;]*'))*pkgdir,
  chain       = md.chain,

  search      = md.searcher,
  loadproc    = function(...) this(...):sync(); return (this(...) or {}).loadfunc end,
  synced      = nil,
}, {
  update      = function(mod, o, ...)
    local self = this(mod)
    if self then
      o = o or self.loaded
      if o then
        mtype[self.node]=o
        instance[self.node]=o
        cache[o]=self
      end
    end
    return o, ...
  end,
  sub         = function(self, it) return self .. it end,
  pkg         = function(self, it) return self(it).topkg end,
  sync        = function(self, status) if not this.synced then for v,k in iter(package.loaded) do this.update(k, v) end end; this.synced=status~=false end,

  __computed = {
    d         = function(self) return self.dd and true or false end,

    name      = function(self) return tostring(self) end,
    short     = function(self) return self.name:match('[^/.]+%.?d?$') end,
    alias     = function(self) return table() end,

-- var names fix
    modz      = function(self) return this.pkgdirs%self.node%get.noinit end,
    file      = function(self) return this.pkgdirs/self.node end,
    dirs      = function(self) return this.pkgdirs*self.node*seen() end,
    base      = function(self) return self.based and self.node:match("^(.*)[./][^./]*$") or self.node end,

-- no changes
    filepath  = function(self) return self.dirfile or self.file end,
    path      = function(self) return self.file or self.dirfile or self.dir end,
    dir       = function(self) local rv=self.dirs[1]; return rv and tostring(rv) end,
    dirfile   = function(self) return self.dir and (this.pkgdirs%self.dir%get.init).init or nil end,
    isroot    = function(self) return #self==1 and this.chain[self[1]] or nil end,
    isfile    = function(self) return self.filepath and true or nil end,
    isdir     = function(self) return self.dir and true or nil end,
    ismodule  = function(self) return self.filepath and true or nil end,
    virtual   = function(self) return ((not self.ismodule) and (not self.isdir)) end,
    exists    = function(self) return self.ismodule or self.isdir end,

    gotloaded = function(self) return next(table(self.aliases)) end,

    loadfile2 = function(self) local up,name,f=this.update,self.node,self.loadfile; return f and function(...) return up(name, call(f,...)) end or nil end,
    loadfile  = function(self) local p=self.filepath; p=p and tostring(p); return p and loadfile(p) end,
    loadpkg   = function(self) local f=self.loaded; return f and function() return f end or nil end,
    loadldr   = function(self) local l=self.loader; return (self.isdir and l) and function() return l end or nil end,
  },
  __computable = {
-- core
    opt       = function(self) return options[self.id] end,
    topkg     = function(self) return self.ismodule and ((self.dir==self.node) and self or self.parent) or nil end,
    parent    = function(self) return #self>1 and mcache.module[join(self[{1,-2}])] or nil end,
    chained   = function(self) return this.chain[self.root] end,
    id        = function(self) return join(self[{self.chained and 2 or 1}]):gsub('%.d$',''):null() end,
    node      = function(self) return self.d and fixer(self.name) or self.name end,
    root      = function(self) return self[1] end,

-- option
    handler   = function(self, ...) if n(...) then self.opt.handler=(...) end; return self.opt.handler end,

-- loading
    loader    = function(self)
      loader=loader or package.loaded['meta.loader'] or require("meta.loader")
      return self.isdir and loader(self.node)
    end,
    req       = function(self) return require(self.node) end,

-- check diff loads
    aliases   = function(self) return self.alias*fn.kk%is.pkgloaded*get.pkgloadtype*is.toindex end,
    loaded    = function(self) return package.loaded[self.gotloaded] end,
    loading   = function(self) return self:update(self.loaded or self.req) end,
    loadh     = function(self) local h=self.parent.handler or fn.noop; local v=self.loading; return v and h(v, self[-1], self.node) end,
    load      = function(self) return self.ismodule and self.loadh end,
    loadfunc  = function(self) return self.loadpkg or self.loadfile2 end,
    get       = function(self) return self.load or self.loader end,

-- misc
    ok        = function(self) return self.exists and self end,
    based     = function(self) return (self.virtual or self.ismodule) and true or nil end,

-- self.d
    dd        = function(self) return (self.ddd or {}).isdir end,
    ddd       = function(self) return (table()..(this.pkgdirs*self.dddd*seen()))[1] end,
    dddd      = function(self) return fixer(self.name) end,
  },
  __call = function(self, ...)
    local o, key = ...
    local name, mod
    if (not n(...)) or (o==nil) or (o=='') or not complex(o) then return nil end
    if type(o)=='string' and o~='' then
      name = sub(o, key)
      local rv = self..name
      if rv then rv.alias[(o~=name and not key) and o or name]=true; return rv end
      return pkg:error('call: nil return value for key', o, key)
    end
    if type(o)=='table' then
      if is.like(this, o) then mod=o else
        mod=mcache.existing.module(o)
      end
      if mod then return mod..key end
    end
    name = instance[o]
    return name and ((self..name)..key) or pkg:error('call: invalid argument value: ', call.inspect(o))
  end,
  __concat = function(self, k)
    if k==nil then return self end
    if type(k)~='string' then return pkg:error('concat: invalid argument type: ', call.inspect(k)) end
    local o = self[{}]
    if rawequal(this, self) then k=sub(k) end
    for p in k:gmatch('[^/]+') do if p~='.' then
      if p=='..' then table.remove(o) else table.insert(o, p) end
    end end
    local name = join(o)
    local r = mcache.existing.module(name) or mcache.module(setmetatable(o, getmetatable(this)), name)
    return r or (pkg:error(':concat(%s) returns' ^ k, name, type(r)))
  end,
  __eq = function(a, b) return tostring(a)==tostring(b) end,
  __iter = function(self, to) return iter(self.modz, function(_,k) return self..k,k end)*to end,
  __index = computed,
  __newindex = setcomputed,
  __div = table.div,
  __mul = table.map,
  __mod = table.filter,
  __name='module',
  __pow = function(self, to)
    if type(to)=='string' then _=this.chain+to end
    if type(to)=='boolean' then
      if to then _=this.chain+self.root else _=this.chain-self.root end
    end
    if is.callable(to) then self.opt.handler=to end
    return self
  end,
  __tostring = function(self) return rawequal(this, self) and 'module' or join(self) end,
})

if not has.value(this.loadproc, package.searchers) then
  table.insert(package.searchers, 1, this.loadproc) end

this:sync(false)

return this