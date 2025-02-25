local pkg = ...
local no = require "meta.no"
local is = require "meta.is"
local mcache = require "meta.mcache"
local iter = require 'meta.iter'
local seen = require 'meta.seen'
local selector = require 'meta.select'
local inspect = require 'inspect'

local computed, setcomputed =
  require "meta.mt.computed",
  require "meta.mt.setcomputed"

local match = require "meta.mt.match"
local root = mcache.root
local function fixer(x) return x and x:gsub('([^%.][^d])$','%1.d') or nil end
local loader

local fn = {
  noop = function(...) return ... end,
  noinit = function(v,k) if k~='init' then return v,k end end,
  init = function(v,k) if k=='init' then return v,k end end,
  nonempty = function(x) return (x and #x>0) and x or nil end,
}
local join = function(o) return table.concat(iter.map(o,tostring), '/') end
local sub, unroot =
  require 'meta.module.sub',
  require 'meta.module.unroot'
local n = function(...) local rv = select('#', ...); return rv>0 and rv or nil end

local options = require 'meta.module.options'
local pkgdirs = require 'meta.module.pkgdirs'
--local searcher = require 'meta.module.searcher'
_,_,_,_,_,_ = pkgdirs, seen, selector, unroot, match, inspect

local this = {}
return mcache("module", sub) ^ setmetatable(this, {
  sub = function(self, it) return self .. it end,
  pkg = function(self, it) return self(it).topkg end,
  __computed = {
    d         = function(self) if self.dd then _=self.node; self.node=fixer(self.name);
                  mcache.module(self, self.node) return true end; return false end,

    id        = function(self) return self.name:match('^[%w%d_]+[%/%.%s](.*)$') end,
    name      = function(self) return join(self) end,
    node      = function(self) return self.name end,

    root      = function(self) return self[1] end,

-- hard edit
    rel       = function(self) return join(self[{2}]):gsub('%.d$','') end,
    short     = function(self) return self.name:match('[^/.]+%.?d?$') end,

-- var names fix
    modz      = function(self) return pkgdirs%self.node%fn.noinit end,
    file      = function(self) return pkgdirs/self.node end,
    pkgdirs   = function(self) return pkgdirs*self.node*seen() end,
    base      = function(self) return self.based and self.node:match("^(.*)[./][^./]*$") or self.node end,

-- no changes
    path      = function(self) return self.file or self.dirfile or self.dir end,
    dir       = function(self) local rv=self.pkgdirs[1]; return rv and tostring(rv) end,
    dirfile   = function(self) return self.dir and (pkgdirs%self.dir%fn.init).init or nil end,
    isroot    = function(self) return (self.exists and #self==1) and true or nil end,
    isfile    = function(self) return (self.file or self.dirfile) and true or nil end,
    isdir     = function(self) return self.dir and true or nil end,
    ismodule  = function(self) return (self.file or self.dirfile) and true or nil end,
    virtual   = function(self) return ((not self.ismodule) and (not self.isdir)) end,
    exists    = function(self) return self.ismodule or self.isdir end,
  },
  __computable = {
-- core
    opt       = function(self) return options[self.rel] end,
    topkg     = function(self) return self.ismodule and ((self.dir==self.node) and self or self.parent) or nil end,
    parent    = function(self) return #self>1 and mcache.module[join(self[{1,-2}])] or nil end,

-- option
    handler   = function(self, ...) if n(...) then self.opt.handler=(...) end; return self.opt.handler end,

-- loading
    loader    = function(self) loader=loader or require("meta.loader"); return self.isdir and loader(self.node) end,
    req       = function(self) return no.require(self.node) end,
    loaded    = function(self) return mcache.loaded[self.node] end,
    loadh     = function(self) local h=self.parent.handler or fn.noop; return h(self.req, self[-1], self.node) end,
    load      = function(self) return self.ismodule and (self.loaded or self.loadh) end,
    get       = function(self) return self.load or self.loader end,

-- misc
    ok        = function(self) return self.exists and self end,
    based     = function(self) return (self.virtual or self.ismodule) and true or nil end,

-- .d masquerading
    dddd      = function(self) return fixer(self.name) end,
    ddd       = function(self) return (pkgdirs*self.dddd*seen())[1] end,
    dd        = function(self) return (self.ddd or {}).isdir end,
  },
  __call = function(self, o, key)
    if type(o)=='table' then
      local ismodule=rawequal(getmetatable(self), getmetatable(o))
      if (not key) and not getmetatable(o) then return mcache.existing.module(o) or self..o end
      if (not key) and ismodule then return o end
      if (not key) and mcache.existing.module(o) then return mcache.module[o] end
--      if (not key) and mcache.existing.module(join(o)) then return mcache.module[join(o)] end
      if not ismodule then o=mcache.instance[o] else o=o.name end
      if not o then return pkg:error('id required') end end
        if type(o)=='string' and o~='' then return self..sub(o, key) end end,
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
  __div = function(self, i)
    local h1 = self.handler
    local load = function(key, h)
      h = h or h1
      local k = sub(key)
      local child = self..k
      if h then return h(child.load, k, child.name) end
      return child.load or child.loader
    end
    if type(i)=='string' then return load(i) end
    if type(i)=='table' then return iter.map(i, load) end
    if i==true then return iter.map(self, fn.noop) end
  end,
  __eq = function(a, b) return tostring(a)==tostring(b) end,
  __iter = function(self, to) return iter(iter.keys(self.modz), to) end,
  __index = computed,
  __newindex = setcomputed,
--  __mod = function(self, to) return end,
--    __mod                     -- pass to iter
--    callable                  -- pass pred to iter
--    boolean                   -- ??
--    string                    -- pat/rex
--  return iterator
  __mul = function(self, to)
--    __mul                     -- pass to iter
--    callable                  -- handler
--    boolean                   -- preload
--    string/number/plain table -- selector (to __index?)
--  return iterator

--  pass __mul / return iter
    if is.callable(to) then return iter.map(self)*to end
    if type(to)=='boolean' then if to then return self.load else return self.loader end end
    if type(to)=='string' or type(to)=='number' or (type(to)=='table' and not getmetatable(to)) then
      return iter(self, function(v,k) return v[to],k end)
    end
--  -1, -5, 2, 5                  -- negative indexes
--  {1}, {2,5}                    -- interval
--  {x,y,z, aaa, bbb, ccc}        -- list of item names
--  {true,false,str const,true}   -- tuple reformat
  end,
  __name='module',
  __pow = function(self, to)
    if type(to)=='string' then _=root+to end
    if type(to)=='boolean' then
      local id=tostring(self):null()
      if id then if to then _=root+id else _=root-id end end
    end
    if is.callable(to) then self.opt.handler=to end
    return self end,
  __tostring = function(self) return join(self) end,
})