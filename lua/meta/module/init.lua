require 'meta.string'
local tuple   = require 'meta.tuple'
local call    = require 'meta.call'
local iter    = require 'meta.iter'
local is      = require 'meta.is'
local mcache  = require 'meta.mcache'
local seen    = require 'meta.seen'

local op      = require 'meta.op'
  op.path     = require 'meta.op.path'
local g       = getmetatable(op.path)

local chain, sub, options, instance, mtype, loaded, searcher, pkgdirs =
  require 'meta.module.chain',
  require 'meta.module.sub',
  require 'meta.module.options',
  require 'meta.module.instance',
  require 'meta.module.type',
  require 'meta.module.loaded',
  require 'meta.module.searcher',
  require 'meta.module.pkgdirs'

local n, join = tuple.n, string.joiner('/')
local loader, this, cache

cache = mcache.module ^ {
  div       = function(self, to)
    if is.tuple(to) and #to==1 then to=to[1] end
    if is.table(to) then
      if not getmetatable(to) then
        to = join(to)
      else
        if is.tuple(to) then return nil end
        if not is.like(this, to) then
          to = instance[to] or to
        end
        if is.like(this, to) then
          to = to.name
        end
      end
    end
    if is.string(to) then
      return self[to] or self[sub(to)] or nil
    end
    return self[to]
  end,
  normalize = sub,
}
this = cache ^ setmetatable({
  pkgdirs     = pkgdirs,
  chain       = chain,
  search      = searcher,
  loadproc    = function(...) loaded(...); return (this(...) or {}).loadfunc end,
  synced      = nil,
}, {
  update      = function(mod, o, ...) if mod then
    local self = is.string(mod) and this(mod) or mod
    if self then
      mod=is.string(mod) and mod or self.node
      if is.string(mod) then loaded(mod,o) end
      if is.toindex(o) then
        loaded[self.name]=o
        mtype[self.name]=o
        instance[self.name]=o
        cache[o]=self
      end
    end
    if o then return o, ... end
  end end,
  hasitem     = function(self, p)
    local name = tostring(self)
    local dirs = this.pkgdirs*name*seen()
    return (this.pkgdirs/(join(name,p)) or dirs[1]) and true or nil
  end,
  sub         = function(self, it) return self .. it end,
  pkg         = function(self, it) return (self..it).topkg end,
  sync        = function(self, status) if not this.synced then for v,k in iter(package.loaded) do this.update(k, v) end end; this.synced=status~=false end,

  __computed = {
    name      = function(self) return tostring(self) end,
    d         = function(self) return #self>0 and (self..('../%s.d'^self[-1])).ok or nil end,
    opt       = function(self) return options[self.id] end,
    id        = function(self) return (self.class or tostring(self)):gsub('%.d$','') end,             -- subname stripped .d
    class     = function(self) return self.chained and join(self[{2}]) end,                           -- object type

    modz      = function(self) return this.pkgdirs%(self.name) end,
    modules   = function(self) return self.modz*is.truthy end,                                        -- modules []
    items     = function(self) return table()..(self.modules*tuple.kk)..(self.subdirs*tuple.vv) end,  -- modules + subdirs
    subdirs   = function(self) return table()..self.dirs*'ls'%'isdir'*-1 end,                         -- all subdirs in all module dirs

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

    loadfunc  = function(self) return self.exists and function(...) if self.exists then return self.pkgload or self:update(call(self.loadfile, ...)) end end or nil end,
  },
  __computable = {
    node      = function(self) return loaded[self.name] end,
    ok        = function(self) return self.exists and self end,
    topkg     = function(self) return self.ismodule and (self.isdir and self or (self..'..')) or nil end,
    parent    = function(self) return self..'..' end,
    chained   = function(self) return this.chain[self.root] end,
    root      = function(self) return self[1] end,
    based     = function(self) return (self.virtual or self.ismodule) and true or nil end,

    chainer   = function(self) return (table()..chain)*self end,

-- option
    handler   = function(self, ...) if n(...) then self.opt.handler=(...) end; return self.opt.handler end,

-- loading
    loadfile  = function(self) local p=self.file; return p and loadfile(p) end,
    loadldr   = function(self) local l=self.loader; return (self.isdir and l) and function() return l end or nil end,

    loader    = function(self) loader=loader or require('meta.loader'); local rv=(self and self.isdir) and loader(self.name); if rv then cache[rv]=self; end; return rv end,
    req       = function(self) return require(self.node) end,
    loaded    = function(self) return package.loaded[self.node] end,
    pkgload   = function(self) local pl=self.loaded; return is.toindex(pl) and pl or nil end,
    loading   = function(self) return self:update(self.loaded or self.req) end,
    loadh     = function(self) local h=self.parent.handler; local v=self.loading; return v and (h and h(v, self[-1], self.name) or v) or nil end,
    load      = function(self) return self.ismodule and self.loadh end,
    get       = function(self) return self.load or self.loader end,
  },
  __call = function(self, o,key,...)
    if key=='' then key=nil end
    if o=='' or o==true then o=nil end
    if o==nil and key==nil and not tuple.n(...) then return nil end
    if key and not o then return self..tuple(key,...) end
    return self..tuple(o,key,...) end,

  __add = function(self, p) if type(self)=='table' and type(p)~='nil' then
    if type(p)=='table' then p=iter.ivalues(cache/p or p) end
    if type(p)=='table' or type(p)=='function' then for k in iter(p) do _=self+k end end
    if p=='..' or (type(p)=='string' and not p:match('^%.*$')) then
      if p:match('[%/]') then return self+p:gmatch('[^/]+') end
      if p=='..' and #self>0 then table.remove(self); return self end
      if p:match('%.') and (#self==0 or not self:hasitem(p)) then return self+p:gmatch('[^%/%.]+') else
        table.insert(self,p) end
      end end return self
  end,

  __concat = function(self, keys) if is.table(self) then
    if keys then loaded(keys) end
    local o = setmetatable(self[{}], getmetatable(self))+keys
    return cache/tostring(o) or cache(o, tostring(o))
  end return nil end,

  __name      = 'module',
  __eq        = rawequal,
  __id        = g.__id,
  __index     = g.__index,
  __newindex  = g.__newindex,
  __le        = g.__le,
  __lt        = g.__lt,
  __sep       = g.__sep,
  __tostring  = g.__tostring,

  __iter      = function(self, to) return iter(self.modules*self, to) end,
  __div       = table.div,
  __mul       = table.map,
  __mod       = table.filter,

  __pow       = function(self, to)
    if type(to)=='string' then _=this.chain+to end
    if type(to)=='boolean' then
      if to then _=this.chain+self.root else _=this.chain-self.root end
    end
    if is.callable(to) then self.opt.handler=to end
    return self
  end,
})

cache['']=this
loaded('meta.module', this)

if not is.has.value(this.loadproc, package.searchers) then
  table.insert(package.searchers, 1, this.loadproc) end

this:sync(false)

return this