local pkg = ...
local mcache = require "meta.mcache"
local iter = require 'meta.iter'
local seen = require 'meta.seen'

local computed, setcomputed =
  require "meta.mt.computed",
  require "meta.mt.setcomputed"

local function fixer(x) return x and x:gsub('([^%.][^d])$','%1.d') or nil end
local loader

local fn = {
  noop = function(...) return ... end,
  noinit = function(v,k) if k~='init' then return v,k end end,
  init = function(v,k) if k=='init' then return v,k end end,
  nonempty = function(x) return (x and #x>0) and x or nil end,
  n = require 'meta.fn.n',
}
local join = function(o) return table.concat(iter.map(o,tostring), '/') end
local sub = require 'meta.module.sub'
--local unroot = require 'meta.module.unroot'
local n = fn.n

local is = {
  callable = require 'meta.is.callable',
}
local has = {
  value = require 'meta.is.has.value',
}

--local queue = require 'meta.module.iqueue'
local options = require 'meta.module.options'
local pkgdirs = require 'meta.module.pkgdirs'
local chain = require 'meta.module.chain'
local instance = require 'meta.module.instance'
local mtype = require 'meta.module.type'
local rev = require 'meta.module.rev'

local this
this = mcache("module", sub) ^ setmetatable({}, {
  search      = require 'meta.module.searcher',
  loadproc    = function(...) return (this(...) or {}).loadfunc end,
  sub         = function(self, it) return self .. it end,
  pkg         = function(self, it) return self(it).topkg end,

  __computed = {
    d         = function(self) return self.dd and true or false end,

    name      = function(self) return join(self) end,
    short     = function(self) return self.name:match('[^/.]+%.?d?$') end,

    alias     = function(self) return table() end,
    pkgloaded = function(self) return self.alias*function(x) return package.loaded[x],x end%toindex end,
    singleton = function(self)
      local kk,vv
      for v,k in iter(self.pkgloaded) do
        if not kk then kk=k; vv=v; else
          if k~=kk and not rawequal(v,vv) then return false end
        end
      end
      return true
    end,

-- var names fix
    modz      = function(self) return pkgdirs%self.node%fn.noinit end,
    file      = function(self) return pkgdirs/self.node end,
    pkgdirs   = function(self) return pkgdirs*self.node*seen() end,
    base      = function(self) return self.based and self.node:match("^(.*)[./][^./]*$") or self.node end,

-- no changes
    filepath  = function(self) return self.dirfile or self.file end,
    path      = function(self) return self.file or self.dirfile or self.dir end,
    dir       = function(self) local rv=self.pkgdirs[1]; return rv and tostring(rv) end,
    dirfile   = function(self) return self.dir and (pkgdirs%self.dir%fn.init).init or nil end,
    isroot    = function(self) return #self==1 and self.chained or nil end,
    isfile    = function(self) return self.filepath and true or nil end,
    isdir     = function(self) return self.dir and true or nil end,
    ismodule  = function(self) return self.filepath and true or nil end,
    virtual   = function(self) return ((not self.ismodule) and (not self.isdir)) end,
    exists    = function(self) return self.ismodule or self.isdir end,

    instance  = function(self) return instance[self.rev] end,
    iloaded   = function(self) return package.loaded[self.instance] end,

    loadfile  = function(self) local p=self.filepath; p=p and tostring(p); print('  loadfile', p); return p and loadfile(p) end,
    loadpkg   = function(self) local r=self.rev; i=self.instance;
      print('  loadpkg', self.name, self.node, r, i, type(package.loaded[r]));
      return r and function() return package.loaded[r] end or nil
    end,
    loadldr   = function(self) local l=self.loader; return l and function() return l end end,
  },
  __computable = {
-- core
    opt       = function(self) return options[self.id] end,
    topkg     = function(self) return self.ismodule and ((self.dir==self.node) and self or self.parent) or nil end,
    parent    = function(self) return #self>1 and mcache.module[join(self[{1,-2}])] or nil end,
    chained   = function(self) return chain[self.root] end,
    id        = function(self) return join(self.chained and self[{2}] or self[{1}]):gsub('%.d$',''):null() end,
    node      = function(self) return self.d and fixer(self.name) or self.name end,
    root      = function(self) return self[1] end,
    rev       = function(self) return rev(self.node) end,
    loadname  = function(self) return rev(self.node) or self.node end,

-- option
    handler   = function(self, ...) if n(...) then self.opt.handler=(...) end; return self.opt.handler end,

-- loading
    loader    = function(self) loader=loader or require("meta.loader"); return self.isdir and loader(self.node) end,
    req       = function(self) local a,b = require(self.loadname); instance[self.loadname]=a; print(' m.req', self.loadname, self.instance, type(a)); return a,b end,
    loaded    = function(self) local rv = package.loaded[self.loadname]; if rv then instance[self.loadname]=rv end; return rv end,
    loading   = function(self) return self.loaded or self.req end,
    loadh     = function(self) local h=self.parent.handler or fn.noop; local v=self.loading; return v and h(self.loading, self[-1], self.node) end,
    load      = function(self) return self.ismodule and self.loadh end,
--    loadfunc  = function(self) return self.loadpkg or self.loadfile or self.loadldr end,
    loadfunc  = function(self) return self.loadpkg or self.loadfile end,
    get       = function(self) print('  m.get', self.loadname); return self.load or self.loader end,

-- misc
    ok        = function(self) return self.exists and self end,
    based     = function(self) return (self.virtual or self.ismodule) and true or nil end,

-- self.d
    dd        = function(self) return (self.ddd or {}).isdir end,
    ddd       = function(self) return (pkgdirs*self.dddd*seen())[1] end,
    dddd      = function(self) return fixer(self.name) end,
  },
  __call = function(self, o, key)
    if type(o)=='table' then
      local ismodule=rawequal(getmetatable(this), getmetatable(o))
      if (not key) and not getmetatable(o) then return mcache.existing.module(o) or self..o end
      if (not key) and ismodule then return o end
      if (not key) and mcache.existing.module(o) then return mcache.module[o] end
      if not ismodule then o=instance[o] else o=o.name end
      if not o then return pkg:error('id required: ' .. o .. ': ' .. instance[o]) end
    end
    if type(o)=='string' and o~='' then
      local name = sub(o, key)
      local m = mcache.existing.module(name) or self..name
      if not m then return nil end
      if m.ismodule then
        m.alias[name]=true
        if not key then m.alias[o]=true end
      end
--      if not key then m.nodes[o]=toindex(package.loaded[o]) end
--      if o~=name then m.nodes[name]=toindex(package.loaded[name]) end
      return m
    end
  end,
  __concat = function(self, k)
    local o = self[{}]
    if type(k)=='string' then
      for p in k:gmatch('[^/]+') do if p~='.' then
        if p=='..' then table.remove(o) else table.insert(o, p) end
      end end
    end
    local name = join(o)
    o.name = name
    return mcache.existing.module(name) or mcache.module(setmetatable(o, getmetatable(self)), name)
  end,
  __eq = function(a, b) return tostring(a)==tostring(b) end,
  __iter = function(self, to) return iter(iter.iter(iter.keys(self.modz), function(k) return to..k,k end), to) end,
  __index = computed,
  __newindex = setcomputed,
  __div = iter.first,
  __mul = iter.map,
  __mod = iter.filter,
  __name='module',
  __pow = function(self, to)
    if type(to)=='string' then _=chain+to end
    if type(to)=='boolean' then to=self.root
      if to then _=chain+to else _=chain-to end
    end
    if is.callable(to) then self.opt.handler=to end
    return self
  end,
  __tostring = function(self) return join(self) end,
})

if not has.value(this.loadproc, package.searchers) then
  table.insert(package.searchers, 1, this.loadproc) end

return this