require 'meta.table'
local lfs   = require 'lfs'
local co    = require 'meta.call'
local iter  = require 'meta.iter'
local fs    = require 'meta.fs'
local tuple = require 'meta.tuple'
local g     = getmetatable(fs.path) or {}

local obj = select(2, lfs.dir('.'))
getmetatable(obj).__call=function(self) return self:next() end

local nondots = function(v) return (v and v~='.' and v~='..') and v or nil end

return setmetatable({},{
__computable= setmetatable({
  items      = function(self) return self.isdir and select(2, lfs.dir(self.rpath)) end,
  ls        = function(self) return self.isdir and iter(co.wrap(function() for n in self.items do co.yieldok(n) end end))*nondots*self.sub or iter(tuple.null) end,
  lsr       = function(self) return self.isdir and iter(co.wrap(function() for a in self.ls do
                if a.isdir then for b in a.lsr do co.yieldok(b) end end; co.yieldok(a); end end)) or iter(tuple.null) end,
  tree      = function(self) return self.isdir and iter(co.pool(self.lsr)) or iter() end,
  rmtree    = function(self) iter.each(self.tree%'nondir'*'rm'); iter.each(self.tree*'rmdir'); return self.rmdir end,
  mkdir     = function(self) return self.isdir or lfs.mkdir(self.rpath) end,
  rmdir     = function(self) return (not self.exists) or (self.isdir and co(lfs.rmdir,self.rpath)) or nil end,
  mkdirp    = function(self) local ex, tail, ok, e = fs.isdir('.') and (self..'') or self.abs, {}
    while (not ex.isdir) and #ex>1 do table.insert(tail, table.remove(ex)) end
    repeat table.insert(ex, table.remove(tail)) if not ex.isdir then ok, e=lfs.mkdir(ex.rpath) end; until #tail<=0 or e
    return ok, e end,
}, {__index=fs}),
__add       = g.__add,
__call      = g.__call,
__concat    = g.__concat,
__eq        = g.__tostring,
__index     = g.__index,
__tostring  = g.__tostring,
__id        = g.__id,
__sep       = g.__sep,
__name      = 'fs.dir',
__le        = g.__le,
__lt        = g.__lt,

__iter      = function(self, it) return iter(self.ls, it) end,
__div       = table.div,
__mul       = table.map,
__mod       = table.filter,

__unm       = function(self) return self.remover end,
})