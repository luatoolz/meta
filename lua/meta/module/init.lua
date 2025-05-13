local pkg = ...
local checker = require "meta.checker"
local call    = require 'meta.call'
local iter    = require 'meta.iter'
local mcache  = require "meta.mcache"

local seen    = require 'meta.seen'
local meta    = require 'meta.lazy'
local fn, md = meta({'fn', 'module'})
local _,_ = fn[{'n', 'noop','k','kk','v','vv','swap'}]
local sub, options, pkgdir, instance, mtype = table.unpack(md[{'sub','options','pkgdir','instance','type','chain','searcher'}])
local computed, setcomputed = require "meta.mt.computed", require "meta.mt.setcomputed"

local is      = require 'meta.is'
local has     = is.has
local complex = checker({["userdata"]=true,["table"]=true,["function"]=true,["CFunction"]=true,["string"]=true,}, type)

local n, join = fn.n, string.joiner('/')
local get = {
  pkgloadtype = function(x) return type(package.loaded[x]) end,
  noinit = function(v,k) if k~='init' then return v,k end end,
  init = function(v,k) if k=='init' then return v,k end end,
}
local loader, this, cache

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
  update      = function(mod, o, ...) if mod then
    local self = this(mod)
    if self then
      o = o or self.loaded
      if o then
        mtype[self.name]=o
        instance[self.name]=o
        cache[o]=self
      end
    end
    if o then return o, ... end
  end end,
  sub         = function(self, it) return self .. it end,
  pkg         = function(self, it) return self(it).topkg end,
  sync        = function(self, status) if not this.synced then for v,k in iter(package.loaded) do this.update(k, v) end end; this.synced=status~=false end,

  __computed = {
    name      = function(self) return tostring(self) end,
    nodes     = function(self) return table() end,
    d         = function(self) return (self..('../%s.d'^self[-1])).ok end,
    opt       = function(self) return options[self.id] end,
    id        = function(self) return join(self[{self.chained and 2 or 1}]):gsub('%.d$',''):null() end,

    modules   = function(self) return self.modz*is.truthy end,
    items     = function(self) return table()..(self.modules*fn.kk)..(self.subdirs*fn.vv) end,
    subdirs   = function(self) return table()..self.dirs*'ls'%'isdir'*-1 end,

    modz      = function(self) return this.pkgdirs%self.name end,
    file      = function(self) return this.pkgdirs/self.name end,
    dirs      = function(self) return this.pkgdirs*self.name*seen() end,
    dir       = function(self) local rv=self.dirs[1]; return rv and tostring(rv) end,

    base      = function(self) return self.based and self.name:match("^(.*)[./][^./]*$") or self.name end,

    path      = function(self) return self.file or self.dir end,
    isfile    = function(self) return self.file and true or nil end,
    ismodule  = function(self) return self.isfile end,
    isroot    = function(self) return #self==1 and this.chain[self[1]] or nil end,
    isdir     = function(self) return self.dir and true or nil end,
    virtual   = function(self) return ((not self.ismodule) and (not self.isdir)) end,
    exists    = function(self) return self.isfile or self.isdir end,

    loadfile2 = function(self) local up,name,f=this.update,self.name,self.loadfile; return f and function(...) return up(name, call(f,...)) end or nil end,
    loadfile  = function(self) local p=self.file; return p and loadfile(p) end,
    loadpkg   = function(self) local f=self.loaded; return f and function() return f end or nil end,
    loadldr   = function(self) local l=self.loader; return (self.isdir and l) and function() return l end or nil end,
  },
  __computable = {
    node      = function(self) return next(table(self.nodes*fn.kk%is.pkgloaded*get.pkgloadtype*is.toindex)) or self.name end,
    ok        = function(self) return self.exists and self end,
    topkg     = function(self) return self.ismodule and (self.isdir and self or (self..'..')) or nil end,
    parent    = function(self) return self..'..' end,
    chained   = function(self) return this.chain[self.root] end,
    root      = function(self) return self[1] end,
    based     = function(self) return (self.virtual or self.ismodule) and true or nil end,

-- option
    handler   = function(self, ...) if n(...) then self.opt.handler=(...) end; return self.opt.handler end,

-- loading
    loader    = function(self)
      loader=loader or package.loaded['meta.loader'] or require("meta.loader")
      return self.isdir and loader(self.name)
    end,
    req       = function(self) return require(self.node or self.name) end,
    loaded    = function(self) return package.loaded[self.node] end,
    loading   = function(self) return self:update(self.loaded or self.req) end,
    loadh     = function(self) local h=self.parent.handler or fn.noop; local v=self.loading; return v and h(v, self[-1], self.name) end,
    load      = function(self) return self.ismodule and self.loadh end,
    loadfunc  = function(self) return self.loadpkg or self.loadfile2 end,
    get       = function(self) return self.load or self.loader end,
  },
  __call = function(self, ...)
    local o, key = ...
    local name, mod, node
    if key=='' then key=nil end
    if o=='' or o==true then o=nil end
    if key and not o then return self(key) end

    if (not n(...)) or (o==nil) or (o=='') or not complex(o) then return nil end
    if type(o)=='string' and o~='' then
      if #self>0 and self.modz[o] then
        name = o
      else
        name = key and sub(o, key) or sub(o)
      end
      local rv = self..name
      node = key and name or o
      if node and (node:match('[%/%.]')==nil or sub(node)~=node) then rawset(rv.nodes,node,true) end
      return rv
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
    local o = self[{}] or {}
    if rawequal(this, self) then k=sub(k) end
    for p in k:gmatch('[^/]+') do if p~='.' then
      if p=='..' then table.remove(o) else table.insert(o, p) end
    end end
    local name = join(o)
    local r = mcache.existing.module(name) or mcache.module(setmetatable(o, getmetatable(this)), name)
    return r or (pkg:error(':concat(%s) returns' ^ k, name, type(r)))
  end,
  __eq        = function(a, b) return tostring(a)==tostring(b) end,
  __iter      = function(self, to) return iter(self.modules*self, to) end,
  __index     = computed,
  __newindex  = setcomputed,
  __div       = table.div,
  __mul       = table.map,
  __mod       = table.filter,
  __name      = 'module',
  __pow       = function(self, to)
    if type(to)=='string' then _=this.chain+to end
    if type(to)=='boolean' then
      if to then _=this.chain+self.root else _=this.chain-self.root end
    end
    if is.callable(to) then self.opt.handler=to end
    return self
  end,
  __tostring  = function(self) return #self>0 and join(self) or '' end,
})

if not has.value(this.loadproc, package.searchers) then
  table.insert(package.searchers, 1, this.loadproc) end

this:sync(false)

return this