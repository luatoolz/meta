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

-- search cached:
-- local found = cache / item
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
  hasitem     = function(self, p) if is.string(p) and not p:match('%/') then                                    -- has submodule or subdir?
    local name = join(string(self),p)
    return (this.pkgdirs/name or (pkgdirs*name)[1]) and true or nil end; return nil end,
  sub         = function(self, it) return self..it end,
  pkg         = function(self, it) return (self..it).topkg end,
  sync        = function(self, status) if not this.synced then iter.each(iter(package.loaded,tuple.swap), this.update) end; this.synced=status~=false end,

  __computed = {
    name      = function(self) return tostring(self) end,                                                       -- normalized module name
    d         = function(self) return #self>0 and (self..('../%s.d'^self[-1])).ok or nil end,                   -- test *.d convention
    id        = function(self) return string((self.class or self.root or ''):gsub('%.d$','')) end,                            -- relative (chained) id with stripped .d (.opt)

    modz      = function(self) return this.pkgdirs%self.name end,                                               -- modz.loader    ='path/loader.lua'
    modules   = function(self) return self.modz*is.truthy end,                                                  -- modules.loader = true
    items     = function(self) return table()..(self.modules*tuple.kk)..(self.subdirs*tuple.vv) end,            -- modules + subdirs array
    subdirs   = function(self) return table()..self.dirs*'ls'%'isdir'*-1 end,                                   -- subdirs array
    subdirz   = function(self) return self.subdirs*tuple.vv end,                                                -- subdirs hash
    file      = function(self) return this.pkgdirs/self.name end,                                               -- module source file
    dirs      = function(self) return this.pkgdirs*self.name*seen() end,                                        -- module dirs array
    dir       = function(self) local rv=self.dirs[1]; return rv and tostring(rv) end,                           -- first dir
    route     = function(self) return (self.ismodule and self.isdir and #self.items>0) and true or nil end,     -- has subitems
    topkg     = function(self) return self.ismodule and (self.isdir and self or (self..'..')) or nil end,       -- current level root mod (dir)

    base      = function(self) return self.based and self.name:match("^(.*)[./][^./]*$") or self.name end,      -- pkg base (dir with submodules)
    virtual   = function(self) return ((not self.ismodule) and (not self.isdir)) end,                           -- virtually (handler generated) modules

    path      = function(self) return self.chfile or self.chdir end,                                            -- path related vars
    isfile    = function(self) return self.chfile and true or nil end,
    ismodule  = function(self) return self.isfile end,
    isroot    = function(self) return #self==1 and this.chain[self[1]] or nil end,
    isdir     = function(self) return self.chdir and true or nil end,
    exists    = function(self) return self.isfile or self.isdir end,

    loadfunc  = function(self) return self.exists and function(...) if self.exists then                         -- loader function returning to require(...)
      if type(rawget(self, 'req'))~='nil' then return rawget(self, 'req') end
      return self.pkgload or self:update(call.pcall(self.loadfile,...)) end end or nil end,
--      return self.pkgload or self:update(self.loadfile(...)) end end or nil end,

    req      = function(self) if self.ismodule then
      local nd = package.loaded[self.node]
--print(' module.req', self.name, self.node, type(nd))
      if type(nd)~='nil' and type(nd)~='number' and (type(nd)~='userdata' or type(getmetatable(nd))~='nil') then
        return require(self.node)
      end
      local lf = this.loadproc(self.node)
      if lf then return lf(self.node) end
--      return require(self.node)
    end end,                            -- require this module
  },
  __computable = {
--    opt       = function(self) return #self>0 and options[self.id] or {} end,                                   -- options, common for mod, *.d, chained
    class     = function(self) return #self>1 and join(self[{2}]) or nil end,                                   -- chained type name (keeps .d)
    node      = function(self) return loaded[self.name] end,                                                    -- found pkgloaded object (using another alias)
    ok        = function(self) return self.exists and self end,                                                 -- existent mod
    parent    = function(self) return self..'..' end,                                                           -- parent module
    root      = function(self) return self[1] end,                                                              -- root module
    based     = function(self) return (self.virtual or self.ismodule) and true or nil end,                      -- based on location

-- chain issues
    chained   = function(self) return #chain>1 and chain[self.name] or nil end,                                 -- use chaned loads
    chainer   = function(self) if self.chained then                                                             -- map style chain searcher
      local rv=(table()..chain); local i=table.find(rv, self.root)
      if i and type(i)=='number' and #rv>1 then
        table.insert(rv,1,table.remove(rv, i))
      end; rv=rv*this; if #self>1 and #rv>0 then rv=rv*tuple.concatter(self.class) end;
        return rv
      end return table() end,

    chmodz    = function(self) return self.chained and table()..  self.chainer*'modz'     or self.modz    end,  -- chained version of module vars
    chmodules = function(self) return self.chained and table()..  self.chainer*'modules'  or self.modules end,
    chitems   = function(self) return self.chained and table()..  self.chainer*'items'    or self.items   end,
    chsubdirs = function(self) return self.chained and table()..  self.chainer*'subdirs'  or self.subdirs end,
    chsubdirz = function(self) return self.chained and table()..  self.chainer*'subdirz'  or self.subdirz end,
    chfile    = function(self) return self.chained and (table().. self.chainer*'file')[1] or self.file    end,
    chdirs    = function(self) return self.chained and table()..  self.chainer*'dirs'     or self.dirs    end,
    chdir     = function(self) return self.chained and (table().. self.chainer*'dir')[1]  or self.dir     end,
    chpkgload = function(self) return self.chained and (table.map(self.chainer,'pkgload',false))[1] or self.pkgload end,

-- option
    handler   = function(self, ...) if n(...) then self.opt.handler=(...)   end; return self.opt.handler end,   -- callable handler for submodule
    inherit   = function(self, ...) if n(...) then self.opt.inherit=(...)   end; return self.opt.inherit end,   -- apply parent options for child loaders
    callempty = function(self, ...) if n(...) then self.opt.callempty=(...) end; return self.opt.callempty end, -- run handler even for nil module value

    opt      = function(self)
      if #self==0 then return nil end
      local opt=options[self.id]
      local p = #self==1 and {} or self.parent.opt
      if rawget(p,'inherit') and not rawget(opt,'inherit') then
        for k,v in pairs(p) do opt[k]=v end
      end return opt end,

-- loading
--    wrapper   = function(self) return function(c) return 'return function() '..c..' end' end end,
    reader    = function(self) return function(p) local f=p and io.open(p, 'r'); if f then local rv=f:read('*a'); f:close(); return rv end end end,
    loadfile  = function(self) local p=self.chfile; return p and (jit and call.pcall(loadstring,self.reader(p)) or loadfile(p)) or nil end,   -- callable evaluating lua loaded code
    loader    = function(self) loader=loader or require('meta.loader')                                          -- return self meta.loader()
      local rv=self.isdir and loader(self.name); if rv then cache[rv]=self end; return rv end,
    req2       = function(self) if self.ismodule then return require(self.node) end end,                            -- require this module
    loaded    = function(self) local req=rawget(self, 'req'); if type(req)~='nil' then return req end; return package.loaded[self.node] end,                                            -- cached object
    pkgload   = function(self) local pl=self.loaded; return is.toindex(pl) and pl or nil end,                   -- cache indexed types but drop other
    loading   = function(self) return self:update(self.chpkgload or self.req) end,                              -- sync loaded name/object
    load      = function(self) local h,v,ce=self.parent.handler,self.loading,self.parent.callempty
      if h and (v or ce) then return h(v,self[-1],self.name) end; return v end,                                 -- run handler
    get       = function(self) return self.load or self.loader end,                                             -- return module / dir loader
  },
  __call = function(self, o,key,...)                                                                            -- new
    if key=='' then key=nil end
    if o=='' or o==true then o=nil end
    if o==nil and key==nil and not tuple.n(...) then return nil end
    if key and not o then return self..tuple(key,...) end
    return self..tuple(o,key,...) end,

  __add = function(self, p) if type(self)=='table' and type(p)~='nil' then                                      -- module path adder
    if type(p)=='table' then p=iter.ivalues(cache/p or p) end
    if type(p)=='table' or type(p)=='function' then
      for k in iter(p) do _=self+k end end
    if p=='..' or (type(p)=='string' and not p:match('^%.*$')) then
      if p:match('[%/]') then return self+p:gmatch('[^/]+') end
      if p=='..' and #self>0 then table.remove(self); return self end
      if p:match('%.') and (not p:match('%.d$')) and (#self==0 or not self:hasitem(p)) then return self+p:gmatch('[^%/%.]+') else
        table.insert(self,p) end
      end end return self end,

  __concat = function(self, keys) if is.table(self) then                                                        -- build module and subpath
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

  __iter      = function(self, to) return iter(self.chmodules*self, to) end,                                    -- iter and operators
  __div       = table.div,
  __mul       = table.map,
  __mod       = table.filter,

  __pow       = function(self, to)
    if is.callable(to) then self.opt.handler=to end                                                             -- callable:  set handler
    if is.string(to) then chain:set(to,true) end                                                                -- string:    chain module
    if is.table(to) and not getmetatable(to) then for k,v in pairs(to) do self.opt[k]=v end end                 -- table:     load options
    if is.boolean(to) and self.root then chain:set(self.root,to) end; return self end,                          -- boolean:   enable/disable self chain
})

cache['']=this                                                                                                  -- cache self
loaded('meta.module', this)

if not is.has.value(this.loadproc, package.searchers) then                                                      -- require() loader
  table.insert(package.searchers, 1, this.loadproc) end

this:sync(false)                                                                                                -- sync self and package.loaded

return this